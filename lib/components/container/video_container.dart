import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:subs/utils/controller.dart';
import 'package:subs/utils/dialog.dart';
import 'package:subs/utils/scanner.dart';

class VideoContainer extends StatefulWidget {
  const VideoContainer({super.key});

  @override
  State<VideoContainer> createState() => _VideoContainerState();
}

class _VideoContainerState extends State<VideoContainer> {

  final Controller controller=Get.find();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          "videoList".tr,
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
                controller.videos.length==0 ? DropTarget(
                  onDragDone: (detail) async {
                    await scanner(context, detail.files.first.path, false);
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
                                await scanner(context, selectedDirectory, false);
                              }
                            }, 
                            child: Text("selectVideoPath".tr)
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
                            onPressed: controller.subPath.value.isEmpty ? null : () async {
                              await scanner(context, controller.subPath.value, true);
                            },
                            child: Text("sameAsSubsPath".tr)
                          )
                        ],
                      ),
                    ),
                  ),
                ) : ReorderableListView.builder(
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex > oldIndex) newIndex -= 1;
                    final item = controller.videos.removeAt(oldIndex);
                    controller.videos.insert(newIndex, item);
                  },
                  itemCount: controller.videos.length,
                  itemBuilder: (BuildContext context, index)=>SizedBox(
                    key: ValueKey(controller.videos[index]),
                    height: 50,
                    child: ListTile(
                      onTap: ()=>showItemDialog(context, controller.videos[index]),
                      title: Text(
                        p.basename(controller.videos[index]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13
                        ),
                      ),
                    ),
                  )
                )
              ),
            ),
          ),
        )
      ],
    );
  }
}