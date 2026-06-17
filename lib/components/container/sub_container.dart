import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:subs/utils/controller.dart';
import 'package:subs/utils/dialog.dart';
import 'package:subs/utils/scanner.dart';

class SubContainer extends StatefulWidget {
  const SubContainer({super.key});

  @override
  State<SubContainer> createState() => _SubContainerState();
}

class _SubContainerState extends State<SubContainer> {

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
      await showItemDialog(context, controller.subs[index]);
    }else if(val==2){
      controller.subs.removeAt(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Obx(
          () => Text(
            "${'subtitleList'.tr}: ${controller.subs.length}",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary
            ),
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
                              await scanner(context, controller.videoPath.value, true);
                            },
                            child: Text("sameAsVideoPath".tr)
                          )
                        ],
                      ),
                    ),
                  ),
                ) : ReorderableListView.builder(
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex > oldIndex) newIndex -= 1;
                    final item = controller.subs.removeAt(oldIndex);
                    controller.subs.insert(newIndex, item);
                  },
                  itemCount: controller.subs.length,
                  itemBuilder: (BuildContext context, index)=>SizedBox(
                    height: 50,
                    key: ValueKey(controller.subs[index]),
                    child: GestureDetector(
                      onSecondaryTapDown: (details){
                        showItemMenu(context, details, index);
                      },
                      child: ListTile(
                        onTap: ()=>showItemDialog(context, controller.subs[index]),
                        title: Text(
                          p.basename(controller.subs[index]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
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