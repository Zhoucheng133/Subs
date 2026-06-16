import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subs/utils/controller.dart';

class Footer extends StatefulWidget {
  const Footer({super.key});

  @override
  State<Footer> createState() => _FooterState();
}

class _FooterState extends State<Footer> {

  final Controller controller=Get.find();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller.outputInput,
            decoration: InputDecoration(
              hintText: 'outputPath'.tr,
              hintStyle: TextStyle(
                color: Colors.grey[400]
              ),
              border: const OutlineInputBorder(),
              isCollapsed: true,
              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 5)
            ),
            readOnly: true,
          ),
        ),
        const SizedBox(width: 10,),
        FilledButton(
          onPressed: () async {
            String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
            if (selectedDirectory != null) {
              controller.outputInput.text=selectedDirectory;
              final prefs=await SharedPreferences.getInstance();
              prefs.setString('output', selectedDirectory);
            }
          }, 
          child: Text("select".tr)
        )
      ],
    );
  }
}