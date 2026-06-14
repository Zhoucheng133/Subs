import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showAbout(BuildContext context) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  await showDialog(
    context: context, 
    builder: (context)=>AlertDialog(
      title: const Text('关于Subs'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 100,
              height: 100,
              child: Image.asset('assets/icon.png')
            ),
          ),
          const Text(
            'Subs', 
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20
            ),
          ),
          const SizedBox(height: 10,),
          Text(
            "v${packageInfo.version}",
            style: TextStyle(
              color: Colors.grey[80],
            ),
          ),
          const SizedBox(height: 15,),
          GestureDetector(
            onTap: () async {
              final Uri url = Uri.parse('https://github.com/Zhoucheng133/Subs');
              await launchUrl(url);
            },
            child: const MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.github,
                    size: 15,
                  ),
                  SizedBox(width: 5,),
                  Text(
                    '本项目地址',
                    style:  TextStyle(
              
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: ()=>showLicensePage(
              applicationName: 'Subs',
              applicationVersion: 'v${packageInfo.version}',
              context: context
            ),
            child: const MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.certificate,
                    size: 15,
                  ),
                  SizedBox(width: 5,),
                  Padding(
                    padding: EdgeInsets.only(bottom: 2),
                    child: Text(
                      '许可证',
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
      actions: [
        FilledButton(
          child: const Text('好的'), 
          onPressed: (){
            Navigator.pop(context);
          }
        )
      ],
    )
  );
}