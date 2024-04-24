// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unrelated_type_equality_checks, unnecessary_brace_in_string_interps

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path/path.dart';
import 'package:process_run/process_run.dart';
import 'package:subs/components/FileList.dart';
import 'package:subs/functions/functions.dart';
import 'package:window_manager/window_manager.dart';
// import 'package:process_run/which.dart';
import 'package:path/path.dart' as path;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 700),
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

  bool running=false;

  int finishedTask=0;
  int allTask=0;

  final func=Func();

  @override
  void initState() {
    super.initState();

    var ffmpegPath = whichSync('ffmpeg');
    ffmpegPathInput.text=ffmpegPath??"";
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
                        onPressed: running ? null : () async {
                          var dir=await func.pickFile();
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
                        onPressed: running ? null : () async {
                          var dir=await func.pickDir();
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
                        onPressed: running ? null : samePathWithVideo ? null : () async {
                          var dir=await func.pickDir();
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
                      func.dialog(context, "操作失败", "没有选择视频路径");
                      return;
                    }else if(subPathInput.text.isEmpty){
                      func.dialog(context, "操作失败", "没有选择字幕路径");
                      return;
                    }
                    setState(() {
                      videoList=func.analyseVideos(videoPathInput.text);
                      subList=func.analyseSubs(subPathInput.text);
                    });
                    func.dialog(context, "分析完成", "共有${videoList.length}个视频和${subList.length}个字幕");
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
                        onPressed: running ? null : () async {
                          var dir=await func.pickDir();
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
                  onPressed: () async {
                    var shell=Shell();
                    if(!running){
                      if(await func.startCheck(context, ffmpegPathInput.text, videoPathInput.text, subPathInput.text, outputPathInput.text, videoList, subList)==true){
                        setState(() {
                          running=true;
                          allTask=videoList.length;
                          finishedTask=0;
                        });
                        
                        for (var element=0; element<videoList.length; element+=1) {
                          if(!running){
                            break;
                          }
                          print("run: ${element}");
                          final ffmpeg=ffmpegPathInput.text;
                          final video=path.Context(style: Style.platform).join(videoPathInput.text, videoList[element]);
                          final sub=path.Context(style: Style.platform).join(subPathInput.text, subList[element]);
                          final output=path.Context(style: Style.platform).join(outputPathInput.text, videoList[element].replaceAll("mkv", "mp4"));
                          final command='''
${ffmpeg} -i "${video}" -vf "ass='${sub}'" "${output}"
''';
                          try {
                            await shell.run(command);
                          } on ShellException catch (_){
                          }
                          setState(() {
                            finishedTask+=1;
                          });
                        }
                      }
                    }else{
                      shell.kill();
                      setState(() {
                        running=false;
                      });
                    }
                  }, 
                  child: running ? Row(
                    children: [
                      Icon(
                        Icons.square_rounded,
                        size: 16,
                      ),
                      SizedBox(width: 5,),
                      Text("${finishedTask}/${allTask}")
                    ],
                  ) : Text("开始任务"),
                )
              ],
            ),
          ],
        ),
      )
    );
  }
}