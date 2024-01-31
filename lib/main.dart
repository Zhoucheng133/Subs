// ignore_for_file: sized_box_for_whitespace, prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously, unnecessary_brace_in_string_interps

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
  runApp(MyApp());
  
  doWhenWindowReady(() {
    const initialSize = Size(800, 700);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.maxSize=initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      home: MainApp(),
    );
  }
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

  // 测试代码
  // void runCommand() async {
  //   String command = 'ffmpeg';
  //   ProcessResult result = await Process.run(command, ['-version'], runInShell: true);

  //   // 处理结果
  //   if (result.exitCode == 0) {
  //     print('FFmpeg 命令执行成功:');
  //     List<String> lines = result.stdout.split('\n');
  //     String firstLine = lines.isNotEmpty ? lines.first : "";
  //     outputInput.text=firstLine;
  //   } else {
  //     print('FFmpeg 命令执行失败:');
  //     print(result.stderr);
  //   }
  // }

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

  Future<void> anaylise(Directory videoDir, Directory subDir, BuildContext context) async {
    await anayliseVideo(videoDir);
    await anayliseSub(subDir);
    showDialog(
      context: context, 
      builder: (BuildContext context) => ContentDialog(
        title: Text("分析完成"),
        content: Text(
          "查找到有${c.videoFiles.length}个视频，${c.subFiles.length}个字幕"
        ),
        actions: [
          FilledButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: Text("好的"),
          )
        ],
      )
    );
  }
  
  Future<void> anayliseSub(Directory directory) async{
    var files=[];
    await for (var entity in directory.list()) {
      if (entity is File && !basename(entity.path).startsWith(".")) {
        if(extension(entity.path)=='.srt' || extension(entity.path)=='.ass'){
          files.add(entity.path);
        }
        // print(basename(entity.path));
      }
    }
    files.sort();
    c.updateSubFiles(files);
  }

  Future<void> anayliseVideo(Directory directory) async {
    var files=[];
    await for (var entity in directory.list()) {
      if (entity is File && !basename(entity.path).startsWith(".")) {
        if(extension(entity.path)=='.mp4' || extension(entity.path)=='.mkv'){
          files.add(entity.path);
        }
        // print(basename(entity.path));
      }
    }
    files.sort();
    c.updateVideoFiles(files);
  }

  Future<void> runService(BuildContext context) async {
    if(c.videoFiles.isEmpty){
      showDialog(
        context: context, 
        builder: (BuildContext context) => ContentDialog(
          title: Text("无法继续"),
          content: Text(
            "所选目录没有找到视频文件，确保你已经点击过\"分析目录\"按钮"
          ),
          actions: [
            FilledButton(
              onPressed: (){
                Navigator.pop(context);
              },
              child: Text("好的"),
            )
          ],
        )
      );
    }else if(c.subFiles.isEmpty){
      showDialog(
        context: context, 
        builder: (BuildContext context) => ContentDialog(
          title: Text("无法继续"),
          content: Text(
            "所选目录没有找到字幕文件"
          ),
          actions: [
            FilledButton(
              onPressed: (){
                Navigator.pop(context);
              },
              child: Text("好的"),
            )
          ],
        )
      );
    }else if(c.videoFiles.length!=c.subFiles.length){
      showDialog(
        context: context, 
        builder: (BuildContext context) => ContentDialog(
          title: Text("无法继续"),
          content: Text(
            "视频文件数量和字幕文件数量不一致"
          ),
          actions: [
            FilledButton(
              onPressed: (){
                Navigator.pop(context);
              },
              child: Text("好的"),
            )
          ],
        )
      );
    }else if(c.outputDir.value==c.videoDir.value){

    }else{
      for(var i=0; i<c.videoFiles.length; i++){
        String videoPath=normalize(c.videoFiles[i]);
        String subPath=normalize(c.subFiles[i]);
        String savePath='${normalize(c.outputDir.value)}/${basename(c.videoFiles[i]).replaceAll("mkv", "mp4")}';
        print(videoPath);
        print(subPath);
        print(savePath);
        print("_____________");
        
        ProcessResult result = await Process.run("ffmpeg", [
          "-i",
          videoPath,
          subPath.endsWith("ass") ? "-vf" : "-vf",
          subPath.endsWith("ass") ? "ass=${subPath}" : "subtitles=${subPath}",
          savePath
        ], runInShell: true);


        if (result.exitCode == 0) {
          print('命令执行成功:');
          print(result.stdout);
        } else {
          print('命令执行失败:');
          print(result.stderr);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                            anaylise(Directory(videoInput.text), Directory(subInput.text), context);
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
                            runService(context);
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
    );
  }
}
