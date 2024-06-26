// ignore_for_file: sized_box_for_whitespace, prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously, unnecessary_brace_in_string_interps

// import 'package:flutter/material.dart';
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:process_run/process_run.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subs/component/subIndex.dart';
import 'package:subs/paras/paras.dart';
import 'package:path/path.dart';

Future<void> main() async {
  runApp(MyApp());

  doWhenWindowReady(() {
    const initialSize = Size(800, 700);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      debugShowCheckedModeBanner: false,
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

  var ffmpegInput=TextEditingController();
  var videoInput=TextEditingController();
  var subInput=TextEditingController();
  var outputInput=TextEditingController();

  bool subVideoSame=false;

  Future<void> getDefaultFFmpeg() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? path = prefs.getString('ffmpegPath');
    if(path!=null){
      setState(() {
        c.updateFFmpegPath(path);
        ffmpegInput.text=path;
      });
    }
  }

  Future<void> setDefaultFFmpeg(path) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('ffmpegPath', path);
  }

  @override
  void initState() {
    super.initState();
    getDefaultFFmpeg();

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
    c.updateFFmpegPath(ffmpegInput.text);
    setDefaultFFmpeg(ffmpegInput.text);
    if(c.videoFiles.isEmpty){
      showDialog(
        context: context, 
        builder: (BuildContext context) => ContentDialog(
          title: Text("无法继续!"),
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
          title: Text("无法继续!"),
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
            "视频文件数量和字幕文件数量不一致!"
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
      showDialog(
        context: context, 
        builder: (BuildContext context) => ContentDialog(
          title: Text("无法继续"),
          content: Text(
            "导出目录不能和视频目录相同!"
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
    }else{
      c.updateFinishedCount(0);
      c.updateStopProcess(false);

      var shell=Shell();

      showDialog(
        context: context, 
        builder: (BuildContext context) => ContentDialog(
          title: Row(
            children: [
              ProgressRing(),
              SizedBox(width: 10,),
              Text("执行中..."),
            ],
          ),
          content: Obx(() => Text("共有${c.videoFiles.length}个任务，已经完成了${c.finishedCount}个")),
          actions: [
            FilledButton(
              onPressed: () {
                c.updateStopProcess(true);
                shell.kill();
              },
              child: Text("取消"),
            )
          ],
        )
      );

      // 运行在这里
      for(var i=0; i<c.videoFiles.length; i++){
        String videoPath=c.videoFiles[i];
        String subPath=c.subFiles[i];
        String savePath=path.join(c.outputDir.value, basename(c.videoFiles[i]).replaceAll("mkv", "mp4"));

        // print("取消执行本次循环: ${c.stopProcess.value}");

        if(c.stopProcess.value){
          break;
        }

        var command='''
${ffmpegInput.text} -i "${videoPath}" -vf "ass='${subPath}'" "${savePath}"
''';
        // print("------\n${command}\n-----");
        try {
          await shell.run(command);
        } on ShellException catch (_){
          c.updateStopProcess(true);
        }

        // print("完成数量${c.finishedCount.value+1}");
        c.updateFinishedCount(c.finishedCount.value+1);
      }
      Navigator.pop(context);
    }
  }

  bool hoverMin=false;
  bool hoverClose=false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              // color: Colors.red,
              height: 30,
              width: MediaQuery.of(context).size.width,
              child: Platform.isWindows ? Row(
                children: [
                  Expanded(child: MoveWindow()),
                  GestureDetector(
                    onTap: () => appWindow.minimize(),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      onEnter: (event) => setState(() { hoverMin=true; }),
                      onExit: (event) => setState(() { hoverMin=false; }),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        color: hoverMin ? Colors.grey[40] : Colors.white,
                        height: 30,
                        width: 30,
                        child: Center(
                          child: FaIcon(
                            FontAwesomeIcons.minus,
                            size: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => appWindow.close(),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      onEnter: (event) => setState(() { hoverClose=true; }),
                      onExit: (event) => setState(() { hoverClose=false; }),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        color: hoverClose ? Colors.red.darker : Colors.red,
                        width: 30,
                        height: 30,
                        child: Center(
                          child: FaIcon(
                            FontAwesomeIcons.xmark,
                            size: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ) : MoveWindow(),
            )
          ),
          Positioned(
            top: 30,
            child: Container(
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
                                  controller: ffmpegInput,
                                ),
                              ),
                              SizedBox(width: 10,),
                              Button(
                                child: Text("选择FFmpeg路径"), 
                                onPressed: () async {
                                  FilePickerResult? ffmpegPath = await FilePicker.platform.pickFiles();
                                  if(ffmpegPath!=null){
                                    c.updateFFmpegPath(ffmpegPath.files.single.path!);
                                    setState(() {
                                      ffmpegInput.text=ffmpegPath.files.single.path!;
                                    });
                                    setDefaultFFmpeg(ffmpegPath.files.single.path);
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
                      height: 400,
                      color: Color.fromARGB(255, 240, 240, 240),
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
