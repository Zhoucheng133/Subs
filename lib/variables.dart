import 'package:get/get.dart';

class Variables extends GetxController {
  RxBool stopTask=false.obs;
  RxInt finished=0.obs;
  RxInt length=0.obs;

  String version='v1.1.1';
}