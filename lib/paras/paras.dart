import 'package:get/get.dart';
class Controller extends GetxController{
  var videoDir="".obs;
  var subDir="".obs;

  void updateVideoDir(data)=>videoDir.value=data;
  void updateSubDir(data)=>subDir.value=data;
}
