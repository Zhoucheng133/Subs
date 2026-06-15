import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subs/utils/controller.dart';

class Content extends StatefulWidget {
  const Content({super.key});

  @override
  State<Content> createState() => _ContentState();
}

class _ContentState extends State<Content> {

  final controller=Get.find<Controller>();

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  void initPrefs() async {
    prefs=await SharedPreferences.getInstance();
  }

  TextEditingController ffmpegInput=TextEditingController();
  late SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .all(20.0),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 120,
                child: Text("ffmpegPath".tr)
              ),
              Expanded(
                child: TextField(
                  controller: controller.ffmpegInput,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    isCollapsed: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 5
                    ),
                  ),
                  readOnly: true,
                )
              ),
              const SizedBox(width: 10,),
              FilledButton(
                onPressed: () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles();
                  if(result!=null){
                    controller.ffmpegInput.text=result.files.single.path!;
                  }
                  if(context.mounted){
                    Navigator.pop(context);
                  }
                  prefs.setString('ffmpeg', controller.ffmpegInput.text);
                  ffmpegInput.text=controller.ffmpegInput.text;
                }, 
                child: Text('select'.tr)
              )
            ],
          )
        ],
      ),
    );
  }
}