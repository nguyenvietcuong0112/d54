

import 'package:cscmobi_app/core/base/base_controller.dart';
import 'package:get/get.dart';

import '../../helper/firebase_helper.dart';

class URLDownloaderDetailController extends BaseController {
  RxInt selectedIndex = 0.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    FirebaseHelper.setTrackingScreenName("URLDownloaderDetailScreen");
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  onSelectBack() {
    Get.back();
  }
}