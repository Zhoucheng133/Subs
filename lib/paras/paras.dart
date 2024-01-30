import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
class Controller extends GetxController{
  var videoDir=TextEditingController().obs;
  var subDir=TextEditingController().obs;

  void updateVideoDir(data)=>videoDir.value.text=data;
  void updateSubDir(data)=>subDir.value.text=data;
}
