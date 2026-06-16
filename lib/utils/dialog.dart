import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:subs/utils/controller.dart';
import 'package:subs/utils/core.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';

Future<void> showAbout(BuildContext context) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  await showDialog(
    context: context, 
    builder: (context)=>AlertDialog(
      title: Text('${"about".tr} Subs'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 100,
              height: 100,
              child: Image.asset('assets/icon.png')
            ),
          ),
          const Text(
            'Subs', 
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20
            ),
          ),
          const SizedBox(height: 10,),
          Text(
            "v${packageInfo.version}",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 15,),
          GestureDetector(
            onTap: () async {
              final Uri url = Uri.parse('https://github.com/Zhoucheng133/Subs');
              await launchUrl(url);
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.github,
                    size: 15,
                  ),
                  SizedBox(width: 5,),
                  Text('prjLink'.tr)
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: ()=>showLicensePage(
              applicationName: 'Subs',
              applicationVersion: 'v${packageInfo.version}',
              context: context
            ),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.certificate,
                    size: 15,
                  ),
                  SizedBox(width: 5,),
                  Padding(
                    padding: EdgeInsets.only(bottom: 2),
                    child: Text(
                      'license'.tr,
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
      actions: [
        ElevatedButton(
          child: Text('ok'.tr), 
          onPressed: (){
            Navigator.pop(context);
          }
        )
      ],
    )
  );
}

Future<void> showErrorDialog(BuildContext context, String title, String message) async {
  await showDialog(
    context: context, 
    builder: (context)=>AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        ElevatedButton(
          child: Text('ok'.tr), 
          onPressed: ()=>Navigator.pop(context)
        )
      ]
    )
  );
}

Future<void> ffmpegDialog(BuildContext context, { bool onInit = false }) async {
  final controller=Get.find<Controller>();
  await showDialog(
    barrierDismissible: !onInit, 
    context: context, 
    builder: (context)=>AlertDialog(
      title: Text("FFmpeg"),
      content: SizedBox(
        width: 400,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.ffmpegInput,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  isCollapsed: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 5)
                ),
                readOnly: true,
              ),
            ),
            const SizedBox(width: 10,),
            FilledButton(
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles();
                if(result!=null){
                  controller.ffmpegInput.text=result.files.single.path!;
                }
              },
              child: Text('select'.tr),
            ),
          ],
        ),
      ),
      actions: [
        if(onInit) TextButton(
          onPressed: () => windowManager.close(), 
          child: Text("quit".tr)
        ),
        ElevatedButton(
          onPressed: () async {
            if(controller.ffmpegInput.text.isEmpty){
              await showErrorDialog(context, "error".tr, "ffmpegPathEmpty".tr);
              return;
            }
            Navigator.pop(context);
          }, 
          child: Text("ok".tr)
        )
      ],
    )
  );
}

Future<void> encoderDialog(BuildContext context) async {
  final controller = Get.find<Controller>();
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("encoder".tr),
      content: Obx(
        () => SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  SizedBox(width: 100, child: Text("videoEncoder".tr)),
                  SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<VideoEncoder>(
                      initialValue: controller.videoEncoder.value,
                      decoration: InputDecoration(
                        isCollapsed: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                        border: OutlineInputBorder(),
                      ),
                      items: VideoEncoder.values.map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.name),
                      )).toList(),
                      onChanged: (v) {
                        if (v != null) controller.videoEncoder.value = v;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  SizedBox(width: 100, child: Text("audioEncoder".tr)),
                  SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<AudioEncoder>(
                      initialValue: controller.audioEncoder.value,
                      decoration: InputDecoration(
                        isCollapsed: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                        border: OutlineInputBorder(),
                      ),
                      items: AudioEncoder.values.map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.name),
                      )).toList(),
                      onChanged: (v) {
                        if (v != null) controller.audioEncoder.value = v;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  SizedBox(width: 100, child: Text("outputFormat".tr)),
                  SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: controller.outputFormat.value,
                      decoration: InputDecoration(
                        isCollapsed: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                        border: OutlineInputBorder(),
                      ),
                      items: ['mp4', 'mkv', 'avi', 'mov', 'webm'].map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      )).toList(),
                      onChanged: (v) {
                        if (v != null) controller.outputFormat.value = v;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  SizedBox(width: 100, child: Text("outputSize".tr)),
                  Row(
                    mainAxisAlignment: .start,
                    children: [
                      Checkbox(
                        splashRadius: 0,
                        value: controller.useSize.value,
                        onChanged: (v) => controller.useSize.value = v!,
                      ),
                      GestureDetector(
                        onTap: (){
                          controller.useSize.value = !controller.useSize.value;
                        },
                        child: Text("specify".tr)
                      )
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  SizedBox(width: 100),
                  Padding(
                    padding: .only(left: 10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 70,
                          child: TextField(
                            controller: controller.widthInput,
                            enabled: controller.useSize.value,
                            decoration: InputDecoration(
                              isCollapsed: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Text("×"),
                        ),
                        SizedBox(
                          width: 70,
                          child: TextField(
                            enabled: controller.useSize.value,
                            controller: controller.heightInput,
                            decoration: InputDecoration(
                              isCollapsed: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text("ok".tr),
        ),
      ],
    ),
  );
}

Future<void> showItemDialog(BuildContext context, String path) async {
  await showDialog(
    context: context, 
    builder: (context)=>AlertDialog(
      title: Text("fileInfo".tr),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: .min,
          children: [
            Row(
              crossAxisAlignment: .start,
              children: [
                SizedBox(
                  width: 150,
                  child: Text("fileName".tr)
                ),
                Expanded(child: Text(p.basename(path)))
              ],
            ),
            Row(
              crossAxisAlignment: .start,
              children: [
                SizedBox(
                  width: 150,
                  child: Text("filePath".tr)
                ),
                Expanded(child: Text(path))
              ],
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: ()=>Navigator.pop(context), 
          child: Text("ok".tr)
        )
      ],
    )
  );
}