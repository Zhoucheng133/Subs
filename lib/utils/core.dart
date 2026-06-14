import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:process_run/process_run.dart';
import 'package:subs/utils/controller.dart';

enum VideoEncoder{
  libx264,
  libx265,
  libxvid,
  av1
}

enum AudioEncoder{
  aac,
  libmp3lame,
  flac,  
}

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
        builder: (context)=>AlertDialog(
          title: const Text('执行任务失败'),
          content: const Text('没有选择输出目录'),
          actions: [
            FilledButton(
              child: const Text('好的'),
              onPressed: (){
                Navigator.pop(context);
              }
            )
          ],
        )
      );
      return;
    }
    if(videos.length!=subs.length){
      await showDialog(
        context: context, 
        builder: (context)=>AlertDialog(
          title: const Text('执行任务失败'),
          content: const Text('视频数量和字幕数量不一致'),
          actions: [
            FilledButton(
              child: const Text('好的'),
              onPressed: (){
                Navigator.pop(context);
              }
            )
          ],
        )
      );
      return;
    }
    if(videoInput==output){
      await showDialog(
        context: context, 
        builder: (context)=>AlertDialog(
          title: const Text('执行任务失败'),
          content: const Text('输出路径不能和视频路径相同'),
          actions: [
            FilledButton(
              child: const Text('好的'),
              onPressed: (){
                Navigator.pop(context);
              }
            )
          ],
        )
      );
      return;
    }

    final Controller c=Get.find();

    late Shell shell;
    late ShellLinesController controller;
    c.finished.value=0;
    c.stopTask.value=false;
    c.length.value=videos.length;

    showDialog(
      context: context, 
      builder: (BuildContext context) => AlertDialog(
        title: const Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 10,),
            Text("执行中...", style: TextStyle()),
          ],
        ),
        content: SizedBox(
          height: 300,
          width: 500,
          child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("共有${c.length.value}个任务，已经完成了${c.finished.value}个"),
              const SizedBox(height: 10,),
              Expanded(
                child: ListView.builder(
                  itemCount: c.log.length,
                  itemBuilder: (context, index)=>Text(
                    c.log[index],
                    
                  ),
                ),
              ),
            ],
          )),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              c.stopTask.value=true;
              shell.kill();
            },
            child: const Text("取消"),
          )
        ],
      )
    );

    for(var i=0; i<videos.length; i++){
      c.log.value=[];
      String videoPath=videos[i];
      String subPath=subs[i];
      String savePath=p.join(output, p.basename(videoPath).replaceAll("mkv", "mp4"));
      if(c.stopTask.value){
        break;
      }
      var command='';
      command='''
${c.ffmpegPath.value} -i "${videoPath}" -vf "ass='${p.basename(subPath)}'" ${sizeCmd(useSize, width, height)}${encoderCmd(videoEncoder, audioEncoder)} "${savePath.replaceAll("\\", "/")}"
''';
      // print(command);
      controller=ShellLinesController(encoding: utf8);
      shell=Shell(workingDirectory: subInput, stdout: controller.sink, stderr: controller.sink);
      try {
        controller.stream.listen((event){
          if(c.log.length>=50){
            c.log.removeAt(0);
          }
          c.log.insert(0, event);
        });
        await shell.run(command);
      } on ShellException catch (_){
      }
      if(!c.stopTask.value){
        c.finished.value=c.finished.value+1;
      }
    }
    if(context.mounted){
      Navigator.pop(context);
      if(!c.stopTask.value){
        showDialog(
          context: context, 
          builder: (context)=>AlertDialog(
            title: const Text('任务已完成'),
            actions: [
              FilledButton(
                child: const Text('好的'),
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