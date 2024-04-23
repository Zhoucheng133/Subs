// ignore_for_file: file_names, prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';

class FileList extends StatefulWidget {

  final List videoList;
  final List subList;


  const FileList({super.key, required this.videoList, required this.subList});

  @override
  State<FileList> createState() => _FileListState();
}

class _FileListState extends State<FileList> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "视频列表",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.videoList.length,
                    itemBuilder: (BuildContext context, int index)=>SizedBox(
                      height: 50,
                      child: Row(
                        children: [
                          Icon(Icons.movie),
                          SizedBox(width: 10,),
                          Expanded(
                            child: Text(
                              widget.videoList[index],
                              maxLines: 2,
                              style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ),
                          SizedBox(width: 10,),
                        ],
                      ),
                    )
                  ),
                )
              ],
            ),
          )
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "字幕列表",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.subList.length,
                    itemBuilder: (BuildContext context, int index)=>SizedBox(
                      height: 50,
                      child: Row(
                        children: [
                          Icon(Icons.subtitles),
                          SizedBox(width: 10,),
                          Expanded(
                            child: Text(
                              widget.subList[index],
                              maxLines: 2,
                              style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ),
                          SizedBox(width: 10,),
                        ],
                      ),
                    )
                  ),
                )
              ],
            ),
          )
        ),
      ],
    );
  }
}