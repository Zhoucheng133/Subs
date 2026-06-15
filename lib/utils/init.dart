import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:process_run/process_run.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subs/utils/controller.dart';
import 'package:window_manager/window_manager.dart';

Future<void> init(BuildContext context) async {
  final prefs=await SharedPreferences.getInstance();
  Controller controller=Get.find<Controller>();
  String? localFFmpegPath=prefs.getString('ffmpeg');
  if(localFFmpegPath!=null){
    controller.ffmpegInput.text=localFFmpegPath;
    return;
  }
  var path = whichSync('ffmpeg');
  final ffmpegInput=TextEditingController();
  if(path==null){
    await showDialog(
      context: context, 
      builder: (context)=>AlertDialog(
        title: Text('noFFmpegFound'.tr),
        content: Text('noFFmpegFoundDescription'.tr),
        actions: [
          TextButton(
            child: Text('quit'.tr), 
            onPressed: ()=>windowManager.close(),
          ),
          FilledButton(
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles();
              if(result!=null){
                controller.ffmpegInput.text=result.files.single.path!;
              }
              if(context.mounted){
                Navigator.pop(context);
              }
              prefs.setString('ffmpeg', controller.ffmpegInput.text);
              ffmpegInput.text=controller.ffmpegInput.text;
            },
            child: Text('selectFFmpeg'.tr)
          )
        ],
      )
    );
  }else{
    controller.ffmpegInput.text=path;
    ffmpegInput.text=controller.ffmpegInput.text;
  }
}