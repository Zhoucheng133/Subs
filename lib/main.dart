// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:subs/components/FileList.dart';
import 'package:subs/functions/functions.dart';
import 'package:window_manager/window_manager.dart';
import 'package:process_run/which.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 800),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: [
        Locale('en', 'US'), // 美国英语
        Locale('zh', 'CN'), // 中文简体
      ],
      theme: ThemeData(
        fontFamily: "Noto",
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange)
      ),
      home: AppContent()
    );
  }
}

class AppContent extends StatefulWidget {
  const AppContent({super.key});

  @override
  State<AppContent> createState() => _AppContentState();
}

class _AppContentState extends State<AppContent> {

  TextEditingController ffmpegPathInput=TextEditingController();
  TextEditingController videoPathInput=TextEditingController();
  TextEditingController subPathInput=TextEditingController();
  TextEditingController outputPathInput=TextEditingController();

  bool samePathWithVideo=false;

  List videoList=[];
  List subList=[];

  @override
  void initState() {
    super.initState();

    var ffmpegPath = whichSync('ffmpeg');
    ffmpegPathInput.text=ffmpegPath??"";
    if(ffmpegPath==null){
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context, 
          builder: (BuildContext context)=>AlertDialog(
            title: Text("此设备没有安装FFmpeg"),
            content: Text("务必将FFmpeg添加到系统环境中，当然你也可以手动选择FFmpeg路径"),
            actions: [
              ElevatedButton(
                onPressed: (){
                  Navigator.pop(context);
                }, 
                child: Text("好的")
              )
            ],
          )
        );
      });
    }
    videoPathInput.addListener(() {
      if(samePathWithVideo){
        subPathInput.text=videoPathInput.text;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            SizedBox(height: 30,),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    enabled: false,
                    controller: ffmpegPathInput,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      isCollapsed: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                    ),
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: Row(
                    children: [
                      Expanded(child: Container()),
                      TextButton(
                        onPressed: () async {
                          var dir=await Func().pickFile();
                          if(dir.isNotEmpty){
                            ffmpegPathInput.text=dir;
                          }
                        }, 
                        child: Text("选择FFmpeg路径")
                      )
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 15,),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    enabled: false,
                    controller: videoPathInput,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      isCollapsed: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                    ),
                  )
                ),
                SizedBox(
                  width: 180,
                  child: Row(
                    children: [
                      Expanded(child: Container()),
                      TextButton(
                        onPressed: () async {
                          var dir=await Func().pickDir();
                          if(dir.isNotEmpty){
                            videoPathInput.text=dir;
                          }
                        }, 
                        child: Text("选择视频路径")
                      )
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 15,),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    enabled: false,
                    controller: subPathInput,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      isCollapsed: true,
                      contentPadding: EdgeInsets.fromLTRB(10, 6, 10, 8),
                    ),
                  )
                ),
                SizedBox(
                  width: 180,
                  child: Row(
                    children: [
                      Expanded(child: Container()),
                      TextButton(
                        onPressed: samePathWithVideo ? null : () async {
                          var dir=await Func().pickDir();
                          if(dir.isNotEmpty){
                            subPathInput.text=dir;
                          }
                        }, 
                        child: Text("选择字幕路径")
                      )
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 15,),
            Row(
              children: [
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    splashRadius: 0,
                    value: samePathWithVideo, 
                    onChanged: (value){
                      setState(() {
                        samePathWithVideo=value;
                      });
                      if(value){
                        subPathInput.text=videoPathInput.text;
                      }
                    }
                  ),
                ),
                SizedBox(width: 5,),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: (){
                      setState(() {
                        samePathWithVideo=!samePathWithVideo;
                      });
                      if(samePathWithVideo==true){ 
                        subPathInput.text=videoPathInput.text;
                      }
                    },
                    child: Text(
                      "字幕路径和视频路径相同"
                    ),
                  ),
                ),
                Expanded(child: Container()),
                ElevatedButton(
                  onPressed: (){
                    if(videoPathInput.text.isEmpty){
                      Func().dialog(context, "操作失败", "没有选择视频路径");
                      return;
                    }else if(subPathInput.text.isEmpty){
                      Func().dialog(context, "操作失败", "没有选择字幕路径");
                      return;
                    }
                    setState(() {
                      videoList=Func().analyseVideos(videoPathInput.text);
                      subList=Func().analyseSubs(subPathInput.text);
                    });
                    Func().dialog(context, "分析完成", "共有${videoList.length}个视频和${subList.length}个字幕");
                  }, 
                  child: Text("分析路径")
                )
              ],
            ),
            SizedBox(height: 10,),
            Expanded(child: FileList(videoList: videoList, subList: subList)),
            SizedBox(height: 10,),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: outputPathInput,
                          decoration: InputDecoration(
                            enabled: false,
                            border: OutlineInputBorder(),
                            isCollapsed: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                          ),
                        )
                      ),
                      SizedBox(width: 10,),
                      TextButton(
                        onPressed: () async {
                          var dir=await Func().pickDir();
                          if(dir.isNotEmpty){
                            outputPathInput.text=dir;
                          }
                        }, 
                        child: Text("选择输出路径")
                      )
                    ],
                  )
                ),
                SizedBox(width: 10,),
                ElevatedButton(
                  onPressed: (){
                    Func().startTask(context, ffmpegPathInput.text, videoPathInput.text, subPathInput.text, videoList, subList);
                  }, 
                  child: Text("开始任务")
                )
              ],
            )
          ],
        ),
      )
    );
  }
}