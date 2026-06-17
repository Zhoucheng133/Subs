import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:process_run/process_run.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subs/utils/types.dart';
import 'package:subs/utils/dialog.dart';

class LanguageType{
  String name;
  Locale locale;

  LanguageType(this.name, this.locale);
}

List<LanguageType> get supportedLocales => [
  LanguageType("English", const Locale("en", "US")),
  LanguageType("简体中文", const Locale("zh", "CN")),
  LanguageType("繁體中文", const Locale("zh", "TW")),
];

class Controller extends GetxController {

  RxBool autoDark=true.obs;
  RxBool darkMode=false.obs;

  Rx<LanguageType> lang=Rx(supportedLocales[0]);

  late SharedPreferences prefs;

  RxInt finished=0.obs;
  RxInt length=0.obs;
  RxBool stopTask=false.obs;
  RxList log=[].obs;

  Rx<VideoEncoder> videoEncoder = Rx(VideoEncoder.libx264);
  Rx<AudioEncoder> audioEncoder = Rx(AudioEncoder.aac);
  RxBool useSize = false.obs;
  TextEditingController widthInput = TextEditingController(text: '1920');
  TextEditingController heightInput = TextEditingController(text: '1080');
  RxString outputFormat = 'mp4'.obs;

  TextEditingController outputInput=TextEditingController();

  RxString videoPath="".obs;
  RxString subPath="".obs;
  RxList<String> videos=RxList([]);
  RxList<String> subs=RxList([]);

  Future<void> initLang() async {
    prefs=await SharedPreferences.getInstance();

    int? langIndex=prefs.getInt("langIndex");

    if(langIndex==null){
      final deviceLocale=PlatformDispatcher.instance.locale;
      final local=Locale(deviceLocale.languageCode, deviceLocale.countryCode);
      int index=supportedLocales.indexWhere((element) => element.locale==local);
      if(index!=-1){
        lang.value=supportedLocales[index];
        lang.refresh();
      }
    }else{
      lang.value=supportedLocales[langIndex];
    }

    outputInput.text=prefs.getString('output')??"";
  }

  void changeLanguage(int index){
    lang.value=supportedLocales[index];
    prefs.setInt("langIndex", index);
    lang.refresh();
    Get.updateLocale(lang.value.locale);
  }

  void darkModeHandler(bool dark){
    if(autoDark.value){
      darkMode.value=dark;
    }
  }

  String sizeCmd(bool useSize, int width, int height){
    if(useSize){
      return "-s ${width}x${height} ";
    }
    return "";
  }

  String encoderCmd(VideoEncoder videoEncoder, AudioEncoder audioEncoder){
    if(videoEncoder==VideoEncoder.av1){
      return "-c:v libaom-av1 -c:a ${audioEncoder.name}";
    }
    return "-c:v ${videoEncoder.name} -c:a ${audioEncoder.name}";
  }

  run(BuildContext context) async {
    if(videos.length == 0 || subs.length == 0){
      await showErrorDialog(context, 'error'.tr, 'videoOrSubEmpty'.tr);
      return;
    }

    if(videos.length!=subs.length){
      await showErrorDialog(context, 'error'.tr, "${'videoSubNotMatch'.tr}\n${videos.length} ${'videos'.tr} : ${subs.length} ${'subs'.tr}");
      return;
    }
    if(videoPath.value == outputInput.text){
      await showErrorDialog(context, 'error'.tr, 'videoAndOutputSame'.tr);
      return;
    }
    late Shell shell;
    late ShellLinesController controller;

    finished.value=0;
    stopTask.value=false;
    length.value=videos.length;

    showDialog(
      context: context, 
      builder: (BuildContext context) => AlertDialog(
        title: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: const CircularProgressIndicator()
            ),
            const SizedBox(width: 10,),
            Text("executing".tr, style: TextStyle()),
          ],
        ),
        content: SizedBox(
          height: 300,
          width: 500,
          child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("taskProgress".trParams({
                'length': length.value.toString(), 
                'finished': finished.value.toString()
              })),
              const SizedBox(height: 10,),
              Expanded(
                child: ListView.builder(
                  itemCount: log.length,
                  itemBuilder: (context, index)=>Text(
                    log[index],
                    
                  ),
                ),
              ),
            ],
          )),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              stopTask.value=true;
              shell.kill();
            },
            child: Text("cancel".tr),
          )
        ],
      )
    );

    for(var i=0; i<videos.length; i++){
      log.value=[];
      String video=videos[i];
      String sub=subs[i];
      String savePath = p.join(outputInput.text, "${p.basenameWithoutExtension(video)}.${outputFormat.value}");
      if(stopTask.value){
        break;
      }
      var command = '';
      command = '''
${p.join(p.dirname(Platform.resolvedExecutable), Platform.isWindows ? "ffmpeg.exe" : "ffmpeg")} -i "${video}" -vf "ass='${p.basename(sub)}'" ${sizeCmd(useSize.value, int.tryParse(widthInput.text) ?? 1920, int.tryParse(heightInput.text) ?? 1080)}${encoderCmd(videoEncoder.value, audioEncoder.value)} "${savePath.replaceAll("\\", "/")}"
''';
      controller=ShellLinesController(encoding: utf8);
      shell=Shell(workingDirectory: subPath.value, stdout: controller.sink, stderr: controller.sink);
      try {
        controller.stream.listen((event){
          if(log.length>=50){
            log.removeAt(0);
          }
          log.insert(0, event);
        });
        await shell.run(command);
      } on ShellException catch (_){
      }
      if(!stopTask.value){
        finished.value=finished.value+1;
      }
    }
    if(context.mounted){
      Navigator.pop(context);
      if(!stopTask.value){
        showDialog(
          context: context, 
          builder: (context)=>AlertDialog(
            title: Text('taskComplete'.tr),
            actions: [
              FilledButton(
                child: Text('ok'.tr),
                onPressed: (){
                  Navigator.pop(context);
                }
              )
            ],
          )
        );
      }
    }
  }
}