// ignore_for_file: sized_box_for_whitespace, prefer_const_constructors, prefer_const_literals_to_create_immutables

// import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:subs/paras/paras.dart';

void main() {
  runApp(MainApp());
  
  doWhenWindowReady(() {
    const initialSize = Size(800, 600);
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
                                  child: Obx(() => 
                                    TextBox(
                                      enabled: false,
                                      controller: c.videoDir.value,
                                    ),
                                  )
                                ),
                                SizedBox(width: 10,),
                                Button(
                                  child: Text("选择视频目录"), 
                                  onPressed: () async {
                                    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
                                    if(selectedDirectory!=null){
                                      c.setVideoDir(selectedDirectory);
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
                                  child: Obx(() => 
                                    TextBox(
                                      enabled: false,
                                      controller: c.subDir.value,
                                    ),
                                  )
                                ),
                                SizedBox(width: 10,),
                                Button(
                                  child: Text("选择字幕目录"), 
                                  onPressed: () async {
                                    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
                                    if(selectedDirectory!=null){
                                      c.setsubDir(selectedDirectory);
                                    }
                                  }
                                ),
                              ],
                            ),
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
