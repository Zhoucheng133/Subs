import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:subs/lang/en_us.dart';
import 'package:subs/lang/zh_cn.dart';
import 'package:subs/lang/zh_tw.dart';
import 'package:subs/utils/controller.dart';
import 'package:subs/main_window.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  Controller controller=Get.put(Controller());
  await controller.init();
  WindowOptions windowOptions = WindowOptions(
    size: Size(700, 600),
    minimumSize: Size(700, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  runApp(const MainApp());
}

class MainTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'zh_CN': zhCN,
    'en_US': en_US,
    'zh_TW': zhTW,
  };
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {

  final Controller controller=Get.find();

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;

    return Obx(()=>
      GetMaterialApp(
        translations: MainTranslations(), 
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate
        ],
        locale: controller.lang.value.locale, 
        supportedLocales: supportedLocales.map((item)=>item.locale).toList(),
        theme: ThemeData(
          brightness: brightness,
          fontFamily: 'PuHui', 
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.red,
            brightness: brightness,
          ),
          textTheme: brightness==Brightness.dark ? ThemeData.dark().textTheme.apply(
            fontFamily: 'PuHui',
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ) : ThemeData.light().textTheme.apply(
            fontFamily: 'PuHui',
          ),
        ),
        home: MainWindow()
      ),
    );
  }
}