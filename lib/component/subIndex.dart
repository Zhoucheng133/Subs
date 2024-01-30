// ignore_for_file: file_names, camel_case_types, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:subs/paras/paras.dart';

class subIndex extends StatefulWidget {
  const subIndex({super.key});

  @override
  State<subIndex> createState() => _subIndexState();
}

class _subIndexState extends State<subIndex> {

  final ScrollController videoScroll=ScrollController();
  final ScrollController subScroll=ScrollController();

  final Controller c=Get.put(Controller());

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Obx(() => 
            ListView.builder(
              controller: videoScroll,
              itemCount: c.videoFiles.length,
              itemBuilder: (BuildContext context, int index){
                return Column(
                  children: [
                    Container(
                      // color: Colors.red,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        // color: Colors.grey[20]
                      ),
                      child: Row(
                        children: [
                          Icon(FluentIcons.m_s_n_videos),
                          SizedBox(width: 10,),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  basename(c.videoFiles[index]),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                                Text(
                                  "${extension(c.videoFiles[index]).substring(1)} 视频",
                                  style: TextStyle(
                                    color: Colors.grey[80]
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5,)
                  ],
                );
              },
            )
          )
        ),
        SizedBox(width: 10,),
        Expanded(
          child: Obx(() => 
            ListView.builder(
              controller: subScroll,
              itemCount: c.subFiles.length,
              itemBuilder: (BuildContext context, int index){
                return Column(
                  children: [
                    Container(
                      // color: Colors.red,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        // color: Colors.grey[20]
                      ),
                      child: Row(
                        children: [
                          Icon(FluentIcons.font_size),
                          SizedBox(width: 10,),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  basename(c.subFiles[index]),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                                Text(
                                  "${extension(c.subFiles[index]).substring(1)} 字幕",
                                  style: TextStyle(
                                    color: Colors.grey[80]
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5,)
                  ],
                );
              },
            )
          )
        ),
      ],
    );
  }
}