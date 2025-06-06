// ignore_for_file: unnecessary_brace_in_string_interps


import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show showLicensePage;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as p;
import 'package:path/path.dart' show basename;
import 'package:process_run/process_run.dart';
import 'package:subs/main_window.dart';
import 'package:subs/variables.dart';
import 'package:url_launcher/url_launcher.dart';

class Task{

  final Variables v = Get.put(Variables());

  String sizeCmd(bool useSize, int width, int height){
    if(useSize){
      return "-s ${width}x${height} ";
    }
    return "";
  }

  String encoderCmd(VideoEncoder videoEncoder, AudioEncoder audioEncoder){
    if(videoEncoder==VideoEncoder.av1){
      return "-c:v libaom-av1 -c:a ${audioEncoder.name}";
    }
    return "-c:v ${videoEncoder.name} -c:a ${audioEncoder.name}";
  }

  void showAbout(BuildContext context){
    showDialog(
      context: context, 
      builder: (context)=>ContentDialog(
        title: Text('关于Subs', style: GoogleFonts.notoSansSc(),),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 100,
                height: 100,
                child: Image.asset('assets/icon.png')
              ),
            ),
            Text(
              'Subs', 
              style: GoogleFonts.notoSansSc(
                fontWeight: FontWeight.bold,
                fontSize: 20
              ),
            ),
            const SizedBox(height: 10,),
            Text(
              v.version.value,
              style: GoogleFonts.notoSansSc(
                color: Colors.grey[80],
              ),
            ),
            const SizedBox(height: 15,),
            GestureDetector(
              onTap: () async {
                final Uri url = Uri.parse('https://github.com/Zhoucheng133/Subs');
                await launchUrl(url);
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.github,
                      size: 15,
                    ),
                    const SizedBox(width: 5,),
                    Text(
                      '本项目地址',
                      style:  GoogleFonts.notoSansSc(
                
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: ()=>showLicensePage(
                applicationName: 'Subs',
                applicationVersion: 'v${v.version.value}',
                context: context
              ),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.certificate,
                      size: 15,
                    ),
                    const SizedBox(width: 5,),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        '许可证',
                        style: GoogleFonts.notoSansSc(
                          fontSize: 13,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
        actions: [
          FilledButton(
            child: Text('好的', style: GoogleFonts.notoSansSc(),), 
            onPressed: (){
              Navigator.pop(context);
            }
          )
        ],
      )
    );
  }

  Future<void> convert(
    List videos, List subs, 
    String output, 
    BuildContext context, 
    String videoInput, 
    String subInput, 
    bool useSize, 
    int width, 
    int height, 
    VideoEncoder videoEncoder, 
    AudioEncoder audioEncoder
  ) async {
    if(output.isEmpty){
      await showDialog(
        context: context, 
        builder: (context)=>ContentDialog(
          title: Text('执行任务失败', style: GoogleFonts.notoSansSc(),),
          content: Text('没有选择输出目录', style: GoogleFonts.notoSansSc(),),
          actions: [
            FilledButton(
              child: Text('好的', style: GoogleFonts.notoSansSc(),),
              onPressed: (){
                Navigator.pop(context);
              }
            )
          ],
        )
      );
      return;
    }else if(videos.length!=subs.length){
      await showDialog(
        context: context, 
        builder: (context)=>ContentDialog(
          title: Text('执行任务失败', style: GoogleFonts.notoSansSc(),),
          content: Text('视频数量和字幕数量不一致', style: GoogleFonts.notoSansSc(),),
          actions: [
            FilledButton(
              child: Text('好的', style: GoogleFonts.notoSansSc(),),
              onPressed: (){
                Navigator.pop(context);
              }
            )
          ],
        )
      );
      return;
    }else if(videoInput==output){
      await showDialog(
        context: context, 
        builder: (context)=>ContentDialog(
          title: Text('执行任务失败', style: GoogleFonts.notoSansSc(),),
          content: Text('输出路径不能和视频路径相同', style: GoogleFonts.notoSansSc(),),
          actions: [
            FilledButton(
              child: Text('好的', style: GoogleFonts.notoSansSc(),),
              onPressed: (){
                Navigator.pop(context);
              }
            )
          ],
        )
      );
      return;
    }
    late Shell shell;
    late ShellLinesController controller;
    v.finished.value=0;
    v.stopTask.value=false;
    v.length.value=videos.length;

    showDialog(
      context: context, 
      builder: (BuildContext context) => ContentDialog(
        title: Row(
          children: [
            const ProgressRing(),
            const SizedBox(width: 10,),
            Text("执行中...", style: GoogleFonts.notoSansSc()),
          ],
        ),
        content: SizedBox(
          height: 300,
          width: 500,
          child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("共有${v.length.value}个任务，已经完成了${v.finished.value}个", style: GoogleFonts.notoSansSc(),),
              const SizedBox(height: 10,),
              Expanded(
                child: ListView.builder(
                  itemCount: v.log.length,
                  itemBuilder: (context, index)=>Text(
                    v.log[index],
                    style: GoogleFonts.notoSansSc(),
                  ),
                ),
              ),
            ],
          )),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              v.stopTask.value=true;
              shell.kill();
            },
            child: Text("取消", style: GoogleFonts.notoSansSc(),),
          )
        ],
      )
    );

    for(var i=0; i<videos.length; i++){
      v.log.value=[];
      String videoPath=videos[i];
      String subPath=subs[i];
      String savePath=p.join(output, basename(videoPath).replaceAll("mkv", "mp4"));
      if(v.stopTask.value){
        break;
      }
      var command='';
      command='''
${v.ffmpegPath.value} -i "${videoPath}" -vf "ass='${basename(subPath)}'" ${sizeCmd(useSize, width, height)}${encoderCmd(videoEncoder, audioEncoder)} "${savePath.replaceAll("\\", "/")}"
''';
      // print(command);
      controller=ShellLinesController(encoding: utf8);
      shell=Shell(workingDirectory: subInput, stdout: controller.sink, stderr: controller.sink);
      try {
        controller.stream.listen((event){
          if(v.log.length>=50){
            v.log.removeAt(0);
          }
          v.log.insert(0, event);
        });
        await shell.run(command);
      } on ShellException catch (_){
      }
      if(!v.stopTask.value){
        v.finished.value=v.finished.value+1;
      }
    }
    if(context.mounted){
      Navigator.pop(context);
      if(!v.stopTask.value){
        showDialog(
          context: context, 
          builder: (context)=>ContentDialog(
            title: Text('任务已完成', style: GoogleFonts.notoSansSc(),),
            actions: [
              FilledButton(
                child: Text('好的', style: GoogleFonts.notoSansSc(),),
                onPressed: (){
                  Navigator.pop(context);
                }
              )
            ],
          )
        );
      }
    }
  }
}