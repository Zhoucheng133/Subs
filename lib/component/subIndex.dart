// ignore_for_file: file_names, camel_case_types, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:subs/paras/paras.dart';

class subIndex extends StatefulWidget {
  const subIndex({super.key});

  @override
  State<subIndex> createState() => _subIndexState();
}

class _subIndexState extends State<subIndex> {

  final ScrollController scroll=ScrollController();
  final ScrollController Hscroll=ScrollController();

  final Controller c=Get.put(Controller());

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      home: Row(
        children: [
          Expanded(
            child: Obx(() => 
              ListView.builder(
                controller: scroll,
                itemCount: c.videoFiles.length,
                itemBuilder: (BuildContext context, int index){
                  return Text(c.videoFiles[index]);
                },
              )
            )
          ),
          SizedBox(width: 10,),
          Expanded(
            child: Container(),
          )
        ],
      )
    );
  }
}