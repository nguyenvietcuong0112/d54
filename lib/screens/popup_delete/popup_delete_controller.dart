import 'dart:async';
import 'package:get/get.dart';
import '../../core/base/base_controller.dart';
import '../../helper/admob_ads_manager.dart';
import '../../helper/admod_ads_type.dart';
import '../../helper/firebase_helper.dart';
import '../../helper/firebase_remote_config_service.dart';

class PopupDeleteController extends BaseController {
  RxString title = "".obs;
  var desc = "".obs;
  RxString titleButton1 = "".obs;
  RxString titleButton2 = "".obs;
  RxInt countDownValue = 3.obs;
  Timer? _timer;
  RxBool isEnableButton1 = true.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    title.value = Get.arguments["title"];
    desc.value = Get.arguments["desc"];
    titleButton1.value = Get.arguments["titleButton1"];
    titleButton2.value = Get.arguments["titleButton2"];
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    if (_timer != null) {
      // _timer!.cancel();
    }
  }

  onSelectCancel() {
    Get.back();
  }

  onSelectConfirm() {
    Get.back(result: {"result": true});
  }
}