import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show Theme;
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' show basename, extension;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subs/service.dart';
import 'package:subs/variables.dart';
import 'package:window_manager/window_manager.dart';
import 'package:process_run/which.dart';

enum VideoEncoder{
  libx264,
  libx265,
  libxvid,
  av1
}

enum AudioEncoder{
  aac,
  libmp3lame,
  flac,  
}

class MainWindow extends StatefulWidget {
  const MainWindow({super.key});

  @override
  State<MainWindow> createState() => _MainWindowState();
}

class _MainWindowState extends State<MainWindow> with WindowListener {

  final Variables v = Get.put(Variables());
  late SharedPreferences prefs;

  void checkFFmpeg(){
    var path = whichSync('ffmpeg');
    if(path==null){
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await showDialog(
          context: context, 
          builder: (context)=>ContentDialog(
            title: const Text('没有检测到FFmpeg'),
            content: const Text('请检查是否安装了FFmpeg以及是否在环境变量中'),
            actions: [
              Button(
                child: const Text('关闭 Subs'), 
                onPressed: ()=>close()
              ),
              FilledButton(
                onPressed: () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles();
                  if(result!=null){
                    v.ffmpegPath.value=result.files.single.path!;
                  }
                  if(context.mounted){
                    Navigator.pop(context);
                  }
                  prefs.setString('ffmpeg', v.ffmpegPath.value);
                  setState(() {
                    ffmpegInput.text=v.ffmpegPath.value;
                  });
                },
                child: const Text('选择FFmpeg路径')
              )
            ],
          )
        );
      });
    }else{
      v.ffmpegPath.value=path;
      setState(() {
        ffmpegInput.text=v.ffmpegPath.value;
      });
    }
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    final String? outputPref = prefs.getString('output');
    if(outputPref!=null){
      output.text=outputPref;
    }
    final String? ffmpegPath=prefs.getString('ffmpeg');
    if(ffmpegPath!=null){
      v.ffmpegPath.value=ffmpegPath;
      setState(() {
        ffmpegInput.text=ffmpegPath;
      });
    }else{
      checkFFmpeg();
    }

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    v.version.value='v${packageInfo.version}';
  }

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    initPrefs();
    videoInput.addListener((){
      if(samePath){
        subInput.text=videoInput.text;
      }
    });
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  void close(){
    windowManager.close();
  }

  void minimize(){
    windowManager.minimize();
  }

  Future<void> pickVideo() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      videoInput.text=selectedDirectory;
    }
  }
  

  Future<void> pickSub() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      subInput.text=selectedDirectory;
    }
  }

  Future<void> pickOutput() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      output.text=selectedDirectory;
      prefs.setString('output', selectedDirectory);
    }
  }

  var ffmpegInput=TextEditingController();
  var videoInput=TextEditingController();
  var subInput=TextEditingController();
  var output=TextEditingController();
  List subs=[];
  List videos=[];
  bool samePath=false;
  Task task=Task();
  bool useSize=false;
  bool useEncoder=false;
  VideoEncoder videoEncoder=VideoEncoder.libx264;
  AudioEncoder audioEncoder=AudioEncoder.aac;

  int width=1920;
  int height=1080;

  Future<void> scanVideo(Directory directory) async {
    var files=[];
    await for (var entity in directory.list()) {
      if (entity is File && !basename(entity.path).startsWith(".")) {
        if(extension(entity.path)=='.mp4' || extension(entity.path)=='.mkv'){
          files.add(entity.path);
        }
      }
    }
    files.sort();
    setState(() {
      videos=files;
    });
  }

  Future<void> scanSub(Directory directory) async {
    var files=[];
    await for (var entity in directory.list()) {
      if (entity is File && !basename(entity.path).startsWith(".")) {
        if(extension(entity.path)=='.srt' || extension(entity.path)=='.ass'){
          files.add(entity.path);
        }
      }
    }
    files.sort();
    setState(() {
      subs=files;
    });
  }

  Future<void> scan(BuildContext context) async {

    if(videoInput.text.isEmpty){
      await showDialog(
        context: context, 
        builder: (context)=>ContentDialog(
          title: const Text('扫描失败'),
          content: const Text('没有选择视频目录'),
          actions: [
            FilledButton(
              child: const Text('好的'),
              onPressed: (){
                Navigator.pop(context);
              }
            )
          ],
        )
      );
      return;
    }else if(subInput.text.isEmpty){
      await showDialog(
        context: context, 
        builder: (context)=>ContentDialog(
          title: const Text('扫描失败'),
          content: const Text('没有选择字幕目录'),
          actions: [
            FilledButton(
              child: const Text('好的'),
              onPressed: (){
                Navigator.pop(context);
              }
            )
          ],
        )
      );
      return;
    }

    final videoPath=Directory(videoInput.text);
    final subPath=Directory(subInput.text);
    await scanVideo(videoPath);
    await scanSub(subPath);
    if(context.mounted){
      showDialog(
        context: context, 
        builder: (context)=>ContentDialog(
          title: const Text('扫描完成'),
          content: Text('共找到${videos.length}个视频文件和${subs.length}个字幕文件'),
          actions: [
            FilledButton(
              child: const Text('好的'),
              onPressed: (){
                Navigator.pop(context);
              }
            )
          ],
        )
      );
    }
  }

  bool hoverAbout=false;

  Future<void> pickFFmpeg() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if(result!=null){
      v.ffmpegPath.value=result.files.single.path!;
    }
    prefs.setString('ffmpeg', v.ffmpegPath.value);
    setState(() {
      ffmpegInput.text=v.ffmpegPath.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).brightness==Brightness.dark ? Colors.black:Colors.white,
      child: Column(
        children: [
          SizedBox(
            height: 30,
            child: Row(
              children: [
                Expanded(child: DragToMoveArea(child: Container(),)),
                Platform.isWindows ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: (){
                        task.showAbout(context);
                      },
                      child: AnimatedContainer(
                        color: hoverAbout ? Theme.of(context).brightness==Brightness.dark ? Colors.grey[200] : Colors.grey[20] : Theme.of(context).brightness==Brightness.dark ? Colors.black : Colors.white,
                        width: 50,
                        duration: const Duration(milliseconds: 200),
                        child: MouseRegion(
                          onEnter: (_){
                            setState(() {
                              hoverAbout=true;
                            });
                          },
                          onExit: (_){
                            setState(() {
                              hoverAbout=false;
                            });
                          },
                          child: const Center(
                            child: FaIcon(
                              FontAwesomeIcons.circleInfo,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    WindowCaptionButton.minimize(
                      onPressed: ()=>minimize(),
                      brightness: Theme.of(context).brightness,
                    ),
                    WindowCaptionButton.close(
                      onPressed: ()=>close(),
                      brightness: Theme.of(context).brightness,
                    ),
                  ],
                ) : Container()
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
            child: Column(
              children: [
                Row(
                  children: [
                    const SizedBox(
                      width: 100,
                      child: Text(
                        'FFmpeg 路径',
                        style: TextStyle(
                          fontSize: 15
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextBox(
                        enabled: false,
                        controller: ffmpegInput,
                      ),
                    ),
                    const SizedBox(width: 10,),
                    Button(
                      child: const Text('选择'), 
                      onPressed: ()=>pickFFmpeg(),
                    )
                  ],
                ),
                const SizedBox(height: 10,),
                Row(
                  children: [
                    const SizedBox(
                      width: 100,
                      child: Text(
                        '视频目录',
                        style: TextStyle(
                          fontSize: 15
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextBox(
                        enabled: false,
                        controller: videoInput,
                      ),
                    ),
                    const SizedBox(width: 10,),
                    Button(
                      child: const Text('选择'), 
                      onPressed: ()=>pickVideo(),
                    )
                  ],
                ),
                const SizedBox(height: 10,),
                Row(
                  children: [
                    const SizedBox(
                      width: 100,
                      child: Text(
                        '字幕目录',
                        style: TextStyle(
                          fontSize: 15
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextBox(
                        enabled: false,
                        controller: subInput,
                      ),
                    ),
                    const SizedBox(width: 10,),
                    Button(
                      onPressed: samePath ? null : ()=>pickSub(),
                      child: const Text('选择')
                    )
                  ],
                ),
                const SizedBox(height: 10,),
                Row(
                  children: [
                    Expanded(
                      child: Checkbox(
                        checked: samePath, 
                        onChanged: (val){
                          setState(() {
                            samePath=val??false;
                          });
                          subInput.text=videoInput.text;
                        },
                        content: const Text('字幕目录和视频目录相同'),
                      ),
                    ),
                    FilledButton(
                      child: const Text('扫描目录'), 
                      onPressed: ()=>scan(context),
                    )
                  ],
                ),
                const SizedBox(height: 10,),
                Row(
                  children: [
                    Checkbox(
                      checked: useSize, 
                      onChanged: (val){
                        setState(() {
                          useSize=val??false;
                        });
                      },
                      content: const Text(
                        '指定大小',
                      ),
                    ),
                    const SizedBox(width: 20,),
                    SizedBox(
                      width: 120,
                      child: NumberBox(
                        clearButton: false,
                        mode: SpinButtonPlacementMode.inline,
                        value: useSize ?  width : 0, 
                        onChanged: useSize ? (val){
                          if(val!=null){
                            setState(() {
                              width=val as int;
                            });
                          }
                        }: null
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 5, right: 5),
                      child: FaIcon(FontAwesomeIcons.xmark),
                    ),
                    SizedBox(
                      width: 120,
                      child: NumberBox(
                        clearButton: false,
                        mode: SpinButtonPlacementMode.inline,
                        value: useSize ?  height : 0, 
                        onChanged: useSize ? (val){
                          if(val!=null){
                            setState(() {
                              height=val as int;
                            });
                          }
                        }: null
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10,),
                Row(
                  children: [
                    Checkbox(
                      checked: useEncoder, 
                      onChanged: (val){
                        setState(() {
                          useEncoder=val??false;
                        });
                      },
                      content: const Text(
                        '指定编码',
                        
                      ),
                    ),
                    const SizedBox(width: 20,),
                    const Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Text("视频: ", style: TextStyle()),
                    ),
                    SizedBox(
                      width: 125,
                      child: ComboBox(
                        isExpanded: true,
                        value: videoEncoder,
                        items: VideoEncoder.values.map((item)=>ComboBoxItem(
                          enabled: useEncoder,
                          value: item,
                          child: Text(item.name, style: const TextStyle()),
                        )).toList(),
                        onChanged: useEncoder ? (item){
                          if(item!=null){
                            setState(() {
                              videoEncoder=item as VideoEncoder;
                            });
                          }
                        } : null,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 10, left: 10),
                      child: Text("音频: ", style: TextStyle()),
                    ),
                    SizedBox(
                      width: 125,
                      child: ComboBox(
                        isExpanded: true,
                        value: audioEncoder,
                        items: AudioEncoder.values.map((item)=>ComboBoxItem(
                          enabled: useEncoder,
                          value: item,
                          child: Text(item.name, style: const TextStyle()),
                        )).toList(),
                        onChanged: useEncoder ? (item){
                          if(item!=null){
                            setState(() {
                              audioEncoder=item as AudioEncoder;
                            });
                          }
                        } : null,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: (videos.isEmpty && subs.isEmpty) ? const Center(
                child: Text(
                  '需要先扫描目录后才能执行任务',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ) : Padding(
                key: const Key("rlt"),
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: videos.length,
                        itemBuilder: (context, index)=>Padding(
                          padding: const EdgeInsets.only(right: 10, top: 5, bottom: 5, left: 10),
                          child: SizedBox(
                            height: 40,
                            child: Row(
                              children: [
                                const Icon(FluentIcons.m_s_n_videos),
                                const SizedBox(width: 10,),
                                Expanded(
                                  child: Text(
                                    basename(videos[index]),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    
                                    
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      )
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: subs.length,
                        itemBuilder: (context, index)=>Padding(
                          padding: const EdgeInsets.only(right: 10, top: 5, bottom: 5, left: 10),
                          child: SizedBox(
                            height: 40,
                            child: Row(
                              children: [
                                const Icon(FluentIcons.font_size),
                                const SizedBox(width: 10,),
                                Expanded(
                                  child: Text(
                                    basename(subs[index]),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      )
                    )
                  ],
                ),
              ),
            )
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
            child: Row(
              children: [
                const Text('输出目录', style: TextStyle(fontSize: 15),),
                const SizedBox(width: 10,),
                Expanded(
                  child: TextBox(
                    enabled: false,
                    controller: output,
                  )
                ),
                const SizedBox(width: 10,),
                Button(
                  child: const Text('选择'), 
                  onPressed: ()=>pickOutput()
                ),
                const SizedBox(width: 10,),
                FilledButton(
                  onPressed: (videos.isEmpty && subs.isEmpty) ? null : ()=>task.convert(videos, subs, output.text, context, videoInput.text, subInput.text, useSize, width, height, videoEncoder, audioEncoder),
                  child: const Text('开始任务')
                )
              ],
            ),
          ),
          Platform.isMacOS ? PlatformMenuBar(
            menus: [
              PlatformMenu(
                label: 'Subs', 
                menus: [
                  PlatformMenuItemGroup(
                    members: [
                      PlatformMenuItem(
                        label: "关于 netPlayer",
                        onSelected: (){
                          task.showAbout(context);
                        }
                      )
                    ]
                  ),
                  const PlatformMenuItemGroup(
                    members: [
                      PlatformProvidedMenuItem(
                        enabled: true,
                        type: PlatformProvidedMenuItemType.hide,
                      ),
                      PlatformProvidedMenuItem(
                        enabled: true,
                        type: PlatformProvidedMenuItemType.quit,
                      ),
                    ]
                  ),
                ]
              ),
              PlatformMenu(
                label: "编辑",
                menus: [
                  PlatformMenuItem(
                    label: "拷贝",
                    shortcut: const SingleActivator(
                      LogicalKeyboardKey.keyC,
                      meta: true
                    ),
                    onSelected: (){}
                  ),
                  PlatformMenuItem(
                    label: "粘贴",
                    shortcut: const SingleActivator(
                      LogicalKeyboardKey.keyV,
                      meta: true
                    ),
                    onSelected: (){}
                  ),
                  PlatformMenuItem(
                    label: "全选",
                    shortcut: const SingleActivator(
                      LogicalKeyboardKey.keyA,
                      meta: true
                    ),
                    onSelected: (){}
                  )
                ]
              ),
              const PlatformMenu(
                label: "窗口", 
                menus: [
                  PlatformMenuItemGroup(
                    members: [
                      PlatformProvidedMenuItem(
                        enabled: true,
                        type: PlatformProvidedMenuItemType.minimizeWindow,
                      ),
                      PlatformProvidedMenuItem(
                        enabled: true,
                        type: PlatformProvidedMenuItemType.toggleFullScreen,
                      )
                    ]
                  )
                ]
              )
            ],
          ) : Container()
        ],
      ),
    );
  }
}