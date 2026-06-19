import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:subs/components/header_button_item.dart';
import 'package:subs/utils/controller.dart';
import 'package:subs/utils/dialog.dart';

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {

  final controller = Get.find<Controller>();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        HeaderButtonItem(buttonSide: ButtonSide.both, icon: Icons.play_arrow_rounded, text: "run".tr, func: () => controller.run(context),),
        Expanded(child: Container()),
        HeaderButtonItem(buttonSide: ButtonSide.left, icon: Icons.tune, text: "encoder".tr, func: ()=>encoderDialog(context)),
        HeaderButtonItem(buttonSide: ButtonSide.mid, icon: FontAwesomeIcons.globe, text: "language".tr, func: ()=>selectLanguage(context), iconSize: 16,),
        HeaderButtonItem(buttonSide: ButtonSide.right, icon: Icons.info_rounded, text: "about".tr, func: ()=>showAbout(context),),
      ],
    );
  }
}