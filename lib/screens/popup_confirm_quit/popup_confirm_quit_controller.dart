import 'dart:async';
import 'package:get/get.dart';
import '../../core/base/base_controller.dart';

class PopupConfirmQuitController extends BaseController {
  RxString title = "".obs;
  RxString desc = "".obs;
  RxString titleButton1 = "".obs;
  RxString titleButton2 = "".obs;
  RxInt countDownValue = 0.obs;
  Timer? _timer;
  RxBool isEnableButton1 = true.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      title.value = (args["title"] ?? "Exit app").toString();
      desc.value = (args["desc"] ?? "Are you sure you want to exit the application?").toString();
      titleButton1.value = (args["titleButton1"] ?? "Yes").toString();
      titleButton2.value = (args["titleButton2"] ?? "No").toString();
    } else {
      title.value = "Exit app";
      desc.value = "Are you sure you want to exit the application?";
      titleButton1.value = "Yes";
      titleButton2.value = "No";
    }
  }

  @override
  void onReady() {
    super.onReady();
    if (countDownValue.value > 0) {
      isEnableButton1.value = false;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (countDownValue.value > 0) {
          countDownValue.value -= 1;
        } else {
          _timer?.cancel();
          isEnableButton1.value = true;
        }
      });
    } else {
      isEnableButton1.value = true;
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void onSelectCancel() {
    _timer?.cancel();
    Get.back();
  }

  void onSelectConfirm() {
    _timer?.cancel();
    Get.back(result: {"result": true});
  }
}