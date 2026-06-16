import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:subs/utils/controller.dart';
import 'package:subs/utils/dialog.dart';

Future<List<String>> scanner(BuildContext context, String path, bool forSub) async {
  final dir=Directory(path);
  List<String> files=[];

  final Controller controller=Get.find();

  await for (var entity in dir.list()) {
    if (entity is File && !basename(entity.path).startsWith(".")) {
      if(!forSub){
        if(extension(entity.path)=='.mp4' || extension(entity.path)=='.mkv'){
          files.add(entity.path);
        }
      }else{
        if(extension(entity.path)=='.srt' || extension(entity.path)=='.ass'){
          files.add(entity.path);
        }
      }
    }
  }
  if(files.isEmpty){
    await showErrorDialog(context, 'error'.tr, 'noMatch'.tr);
    return [];
  }

  if(forSub){
    controller.subPath.value=path;
    controller.subs.value=files;
  }else{
    controller.videoPath.value=path;
    controller.videos.value=files;
  }

  return files;
}