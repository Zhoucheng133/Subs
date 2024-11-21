// ignore_for_file: unnecessary_brace_in_string_interps


import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as p;
import 'package:path/path.dart' show basename;
import 'package:process_run/process_run.dart';
import 'package:subs/variables.dart';

class Task{

  final Variables v = Get.put(Variables());

  Future<void> convert(List videos, List subs, String output, BuildContext context, String videoInput, String subInput) async {
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
    
    v.finished.value=0;
    v.stopTask.value=false;
    v.length.value=videos.length;

    var shell=Shell(workingDirectory: subInput);

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
        content: Obx(() => Text("共有${v.length.value}个任务，已经完成了${v.finished.value}个", style: GoogleFonts.notoSansSc(),)),
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
      String videoPath=videos[i];
      String subPath=subs[i];
      String savePath=p.join(output, basename(videoPath).replaceAll("mkv", "mp4"));
      if(v.stopTask.value){
        break;
      }
      var command='''
ffmpeg -i "${videoPath.replaceAll("\\", "/")}" -c:v libx264 -vf "ass='${basename(subPath)}'" "${savePath.replaceAll("\\", "/")}"
''';
      try {
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