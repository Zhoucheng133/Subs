import 'package:get/get.dart';
class Controller extends GetxController{
  var ffmpegPath="".obs;
  var videoDir="".obs;
  var subDir="".obs;
  var outputDir="".obs;

  var videoFiles=[].obs;
  var subFiles=[].obs;

  var finishedCount=0.obs;

  var processId=0.obs;
  var stopProcess=false.obs;

  void updateVideoDir(data) => videoDir.value=data;
  void updateSubDir(data) => subDir.value=data;
  void updateOutputDir(data) => outputDir.value=data;
  void updateFFmpegPath(data) => ffmpegPath.value=data;
  void updateVideoFiles(data) => videoFiles.value=data;
  void updateSubFiles(data) => subFiles.value=data;
  void updateFinishedCount(data) => finishedCount.value=data;
  void updateProcessId(data){
    processId.value=data;
    // print("更新id");
  }
  void updateStopProcess(data) => stopProcess.value=data;
}
