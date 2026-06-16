import 'dart:io';

import 'package:flutter/material.dart';
import 'package:subs/components/content.dart';
import 'package:subs/components/footer.dart';
import 'package:subs/components/header.dart';
import 'package:subs/utils/init.dart';
import 'package:window_manager/window_manager.dart';

class MainWindow extends StatefulWidget {
  const MainWindow({super.key});

  @override
  State<MainWindow> createState() => _MainWindowState();
}

class _MainWindowState extends State<MainWindow> with WindowListener {

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      init(context);
    });
  }

 @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  bool isMax=false;

  @override
  void onWindowMaximize(){
    setState(() {
      isMax=true;
    });
  }
  
  @override
  void onWindowUnmaximize(){
    setState(() {
      isMax=false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 30,
            child: Row(
              children: [
                Expanded(child: DragToMoveArea(child: Container())),
                if(Platform.isWindows) Row(
                  children: [
                    WindowCaptionButton.minimize(
                      brightness: Theme.of(context).brightness,
                      onPressed: ()=>windowManager.minimize()
                    ),
                    isMax ? WindowCaptionButton.unmaximize(
                      brightness: Theme.of(context).brightness,
                      onPressed: ()=>windowManager.unmaximize()
                    ) : WindowCaptionButton.maximize(
                      brightness: Theme.of(context).brightness,
                      onPressed: ()=>windowManager.maximize()
                    ),  
                    WindowCaptionButton.close(
                      brightness: Theme.of(context).brightness,
                      onPressed: ()=>windowManager.close()
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: .only(left: 20, right: 20, top: 10, bottom: 20),
              child: Column(
                children: [
                  Header(),
                  Expanded(
                    child: Padding(
                      padding: .symmetric(vertical: 5),
                      child: Content(),
                    )
                  ),
                  Footer()
                ],
              ),
            )
          )
        ],
      ),
    );
  }
}