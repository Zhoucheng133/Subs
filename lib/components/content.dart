import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Content extends StatefulWidget {
  const Content({super.key});

  @override
  State<Content> createState() => _ContentState();
}

class _ContentState extends State<Content> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  "videoList".tr,
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
                    ),
                  ),
                )
              ],
            )
          ),
          const SizedBox(width: 15,),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  "subtitleList".tr,
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
                    ),
                  ),
                )
              ],
            )
          ),
        ],
      ),
    );
  }
}