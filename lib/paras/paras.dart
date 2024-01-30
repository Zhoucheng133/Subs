import 'package:get/get.dart';
class Controller extends GetxController{
  var videoDir="".obs;
  var subDir="".obs;
  var outputDir="".obs;

  void updateVideoDir(data) => videoDir.value=data;
  void updateSubDir(data) => subDir.value=data;
  void updateOutputDir(data) => outputDir.value=data;
}
