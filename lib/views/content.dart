import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subs/components/header.dart';
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
      padding: .only(left: 20, right: 20, top: 10),
      child: Column(
        children: [
          Header()
        ],
      ),
    );
  }
}