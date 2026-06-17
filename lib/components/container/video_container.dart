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

  Future<void> showItemMenu(BuildContext context, TapDownDetails details, int index) async {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset position = overlay.localToGlobal(details.globalPosition);
    var val=await showMenu(
      context: context,
      // 菜单位置
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 50,
        position.dy + 50,
      ),
      items: [
        PopupMenuItem(
          value: 1,
          child: Row(
            mainAxisSize: .min,
            children: [
              Icon(
                Icons.info_rounded,
                size: 18,
              ),
              const SizedBox(width: 5,),
              Text('fileInfo'.tr),
            ],
          ),
          height: 40,
        ),
        PopupMenuItem(
          value: 2,
          child: Row(
            mainAxisSize: .min,
            children: [
              Icon(
                Icons.delete_rounded,
                size: 18,
              ),
              const SizedBox(width: 5,),
              Text('delete'.tr),
            ],
          ),
          height: 40,
        ),
      ]
    );
    if(val==1){
      await showItemDialog(context, controller.videos[index]);
    }else if(val==2){
      controller.videos.removeAt(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          "${'videoList'.tr}: ${controller.videos.length}",
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
                    child: GestureDetector(
                      onSecondaryTapDown: (details){
                        showItemMenu(context, details, index);
                      },
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