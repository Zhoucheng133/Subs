import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:subs/utils/controller.dart';
import 'package:subs/utils/scanner.dart';

class SubContainer extends StatefulWidget {
  const SubContainer({super.key});

  @override
  State<SubContainer> createState() => _SubContainerState();
}

class _SubContainerState extends State<SubContainer> {

  final Controller controller=Get.find();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          "subtitleList".tr,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary
          ),
        ),
        Expanded(
          child: Padding(
            padding: .only(top: 5),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness==Brightness.light ? Colors.white : Colors.white.withAlpha(20),
                borderRadius: BorderRadius.circular(10)
              ),
              child: Obx(()=>
                controller.subs.length==0 ? DropTarget(
                  onDragDone: (detail) async {
                    await scanner(context, detail.files.first.path, true);
                  },
                  child: Center(
                    child: Padding(
                      padding: .only(top: 15),
                      child: Column(
                        mainAxisSize: .min,
                        children: [
                          FilledButton(
                            onPressed: () async {
                              String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
                              if (selectedDirectory != null) {
                                await scanner(context, selectedDirectory, true);
                              }
                            }, 
                            child: Text("selectSubtitlePath".tr)
                          ),
                          Padding(
                            padding: .only(top: 10),
                            child: Text(
                              "tipDrop".tr,
                              style: TextStyle(
                                color: Colors.grey
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: controller.videoPath.value.isEmpty ? null : () async {
                              await scanner(context, controller.subPath.value, true);
                            },
                            child: Text("sameAsVideoPath".tr)
                          )
                        ],
                      ),
                    ),
                  ),
                ) : ListView.builder(
                  itemCount: controller.subs.length,
                  itemBuilder: (BuildContext context, index)=>Text(controller.subs[index])
                )
              ),
            ),
          ),
        )
      ],
    );
  }
}