import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:subs/components/header_button_item.dart';
import 'package:subs/utils/dialog.dart';

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: .end,
      children: [
        HeaderButtonItem(buttonSide: ButtonSide.left, icon: Icons.settings_rounded, text: "FFmpeg", func: () => ffmpegDialog(context),),
        HeaderButtonItem(buttonSide: ButtonSide.mid, icon: Icons.tune, text: "encode".tr,),
        HeaderButtonItem(buttonSide: ButtonSide.right, icon: Icons.info_rounded, text: "about".tr, func: ()=>showAbout(context),),
      ],
    );
  }
}