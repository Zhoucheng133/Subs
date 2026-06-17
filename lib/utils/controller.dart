import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subs/utils/core.dart';
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

  run(BuildContext context){
    // TODO 测试
    print(Platform.resolvedExecutable);
    if(videos.length==0 || subs.length==0){
      showErrorDialog(context, "error".tr, "videoOrSubEmpty".tr);
      return;
    }
  }
}