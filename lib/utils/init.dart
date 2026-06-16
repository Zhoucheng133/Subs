import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:process_run/process_run.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subs/utils/controller.dart';
import 'package:subs/utils/dialog.dart';

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
    await ffmpegDialog(context, onInit: true);
  }else{
    controller.ffmpegInput.text=path;
    ffmpegInput.text=controller.ffmpegInput.text;
  }
}