import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:process_run/process_run.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subs/utils/controller.dart';
import 'package:window_manager/window_manager.dart';

Future<void> init(BuildContext context, setState) async {
  final prefs=await SharedPreferences.getInstance();
  Controller controller=Get.find<Controller>();
  String? localFFmpegPath=prefs.getString('ffmpeg');
  if(localFFmpegPath!=null){
    controller.ffmpegPath.value=localFFmpegPath;
    return;
  }
  var path = whichSync('ffmpeg');
  final ffmpegInput=TextEditingController();
  if(path==null){
    await showDialog(
      context: context, 
      builder: (context)=>AlertDialog(
        title: const Text('没有检测到FFmpeg'),
        content: const Text('请检查是否安装了FFmpeg以及是否在环境变量中'),
        actions: [
          TextButton(
            child: const Text('关闭 Subs'), 
            onPressed: ()=>windowManager.close(),
          ),
          FilledButton(
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles();
              if(result!=null){
                controller.ffmpegPath.value=result.files.single.path!;
              }
              if(context.mounted){
                Navigator.pop(context);
              }
              prefs.setString('ffmpeg', controller.ffmpegPath.value);
              setState(() {
                ffmpegInput.text=controller.ffmpegPath.value;
              });
            },
            child: const Text('选择FFmpeg路径')
          )
        ],
      )
    );
  }else{
    controller.ffmpegPath.value=path;
    setState(() {
      ffmpegInput.text=controller.ffmpegPath.value;
    });
  }
}