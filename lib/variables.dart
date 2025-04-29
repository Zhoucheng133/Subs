import 'package:get/get.dart';

class Variables extends GetxController {
  RxBool stopTask=false.obs;
  RxInt finished=0.obs;
  RxInt length=0.obs;

  RxList log=[].obs;

  RxString version=''.obs;

  RxString ffmpegPath=''.obs;
}