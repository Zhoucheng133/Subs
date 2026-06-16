import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:subs/utils/controller.dart';
import 'package:subs/utils/scanner.dart';

class ListContainer extends StatefulWidget {

  final bool forSub;

  const ListContainer({super.key, required this.forSub});

  @override
  State<ListContainer> createState() => _ListContainerState();
}

class _ListContainerState extends State<ListContainer> {

  final Controller controller=Get.find();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          widget.forSub ? "subtitleList".tr : "videoList".tr,
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
                    controller.videos.value=await scanner(context, detail.files.first.path, widget.forSub);
                  },
                  child: Center(
                    child: Column(
                      mainAxisSize: .min,
                      children: [
                        FilledButton(
                          onPressed: (){}, 
                          child: Text( widget.forSub ? "selectSubPath" : "selectVideoPath".tr)
                        ),
                        Padding(
                          padding: .only(top: 10),
                          child: Text(
                            "tipDrop".tr,
                            style: TextStyle(
                              color: Colors.grey
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ) : Container()
              ),
            ),
          ),
        )
      ],
    );
  }
}