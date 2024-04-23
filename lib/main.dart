// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:window_manager/window_manager.dart';

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
  TextEditingController ffmpegPathInput=TextEditingController();
  TextEditingController videoPathInput=TextEditingController();
  TextEditingController subPathInput=TextEditingController();

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
      home: Scaffold(
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
                        contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    child: Row(
                      children: [
                        Expanded(child: Container()),
                        ElevatedButton(onPressed: (){}, child: Text("选择FFmpeg路径"))
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
                        contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                      ),
                    )
                  ),
                  SizedBox(
                    width: 180,
                    child: Row(
                      children: [
                        Expanded(child: Container()),
                        ElevatedButton(onPressed: (){}, child: Text("选择视频路径"))
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
                        contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                      ),
                    )
                  ),
                  SizedBox(
                    width: 180,
                    child: Row(
                      children: [
                        Expanded(child: Container()),
                        ElevatedButton(onPressed: (){}, child: Text("选择字幕路径"))
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        )
      ),
    );
  }
}
