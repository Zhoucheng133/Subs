// ignore_for_file: sized_box_for_whitespace, prefer_const_constructors, prefer_const_literals_to_create_immutables

// import 'package:flutter/material.dart';
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:subs/component/subIndex.dart';
import 'package:subs/paras/paras.dart';

void main() {
  runApp(MainApp());
  
  doWhenWindowReady(() {
    const initialSize = Size(800, 700);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.maxSize=initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {

  final Controller c=Get.put(Controller());

  var videoInput=TextEditingController();
  var subInput=TextEditingController();
  var outputInput=TextEditingController();

  bool subVideoSame=false;

  @override
  void initState() {
    super.initState();

    ever(c.videoDir, (callback){
      if(subVideoSame==true){
        c.updateSubDir(c.videoDir.value);
        subInput.text=c.videoDir.value;
      }
    });
  }

  Future<void> anayliseVideo(Directory directory) async {
    var files=[];
    await for (var entity in directory.list()) {
      if (entity is File) {
        if(extension(entity.path)=='.mp4' || extension(entity.path)=='.mkv'){
          files.add(entity.path);
        }
        // print(basename(entity.path));
      }
    }
    files.sort();
    c.updateVideoFiles(files);
  }

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      home: Container(
        color: Colors.white,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: SizedBox(
                height: 30,
                width: MediaQuery.of(context).size.width,
                child: WindowTitleBarBox(
                  child: MoveWindow(),
                ),
              )
            ),
            Positioned(
              top: 30,
              child: Container(
                // color: Colors.red,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30, top: 30),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextBox(
                                    enabled: false,
                                    controller: videoInput,
                                  ),
                                ),
                                SizedBox(width: 10,),
                                Button(
                                  child: Text("选择视频目录"), 
                                  onPressed: () async {
                                    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
                                    if(selectedDirectory!=null){
                                      c.updateVideoDir(selectedDirectory);
                                      setState(() {
                                        videoInput.text=selectedDirectory;
                                      });
                                    }
                                  }
                                ),
                              ],
                            )
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextBox(
                                    enabled: false,
                                    controller: subInput,
                                  ),
                                ),
                                SizedBox(width: 10,),
                                Button(
                                  onPressed: subVideoSame==true ? null : () async {
                                    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
                                    if(selectedDirectory!=null){
                                      c.updateSubDir(selectedDirectory);
                                      setState(() {
                                        subInput.text=selectedDirectory;
                                      });
                                    }
                                  },
                                  child: Text("选择字幕目录")
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 10,),
                      Row(
                        children: [
                          Text("字幕和视频目录相同"),
                          SizedBox(width: 10,),
                          ToggleSwitch(
                            checked: subVideoSame, 
                            onChanged: (val){
                              setState(() {
                                subVideoSame=val;
                              });
                              if(val==true){
                                c.updateSubDir(videoInput.text);
                                // subInput=videoInput.text;
                                setState(() {
                                  subInput.text=videoInput.text;
                                });
                              }
                            }
                          ),
                          Expanded(child: Container()),
                          FilledButton(
                            onPressed: (subInput.text=="" || videoInput.text=="") ? null : (){
                              // TODO 分析目录

                              anayliseVideo(Directory(videoInput.text));
                            },
                            child: Text("分析目录"), 
                          )
                        ],
                      ),
                      SizedBox(height: 20,),
                      Container(
                        width: double.infinity,
                        height: 430,
                        // color: Color.fromARGB(255, 240, 240, 240),
                        child: subIndex(),
                      ),
                      SizedBox(height: 10,),
                      Row(
                        children: [
                          Expanded(
                            child: TextBox(
                              enabled: false,
                              controller: outputInput,
                            )
                          ),
                          SizedBox(width: 10,),
                          Button(
                            child: Text("选择导出目录"), 
                            onPressed: () async {
                              String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
                              if(selectedDirectory!=null){
                                c.updateOutputDir(selectedDirectory);
                                setState(() {
                                  outputInput.text=selectedDirectory;
                                });
                              }
                            }
                          ),
                          SizedBox(width: 10,),
                          FilledButton(
                            onPressed: outputInput.text!="" && subInput.text!="" && videoInput.text!="" ? (){

                            } : null,
                            child: Text("开始执行"),
                          )
                        ],
                      )
                    ],
                  )
                )
              )
            )
          ],
        ),
      )
    );
  }
}
