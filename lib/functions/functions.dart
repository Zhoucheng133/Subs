import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class Func{
  Future<String> pickDir() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) {
      return "";
    }
    return selectedDirectory;
  }

  Future<String> pickFile() async{
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if(result==null){
      return "";
    }
    return result.files.single.path!;
  }

  List analyseVideos(String directoryPath){
    final directory = Directory(directoryPath);
    var fileNames=[];
    if (directory.existsSync()) {
      final List<FileSystemEntity> entities = directory.listSync(recursive: true);
      for (final entity in entities) {
        if (entity is File) {
          if(path.basename(entity.path).endsWith("mkv") || path.basename(entity.path).endsWith("mp4")){
            fileNames.add(path.basename(entity.path));
          }
        }
      }
    } else {
      return fileNames;
    }
    fileNames.sort((a, b){
      return a.compareTo(b);
    });
    return fileNames;
  }

  List analyseSubs(String directoryPath){
    final directory = Directory(directoryPath);
    var fileNames=[];
    if (directory.existsSync()) {
      final List<FileSystemEntity> entities = directory.listSync(recursive: true);
      for (final entity in entities) {
        if (entity is File) {
          if(path.basename(entity.path).endsWith("ass") || path.basename(entity.path).endsWith("srt")){
            fileNames.add(path.basename(entity.path));
          }
        }
      }
    } else {
      return fileNames;
    }
    fileNames.sort((a, b){
      return a.compareTo(b);
    });
    return fileNames;
  }

  void dialog(BuildContext context, String title, String content){
    showDialog(
      context: context, 
      builder: (context)=>AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          ElevatedButton(
            onPressed: ()=>Navigator.pop(context), child: const Text("好的")
          )
        ],
      )
    );
  }
}