import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:subs/components/container/sub_container.dart';
import 'package:subs/components/container/video_container.dart';
import 'package:subs/utils/controller.dart';

class Content extends StatefulWidget {
  const Content({super.key});

  @override
  State<Content> createState() => _ContentState();
}

class _ContentState extends State<Content> {

  final Controller controller=Get.find();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: VideoContainer()
          ),
          const SizedBox(width: 15,),
          Expanded(
            child: SubContainer()
          ),
        ],
      ),
    );
  }
}