

import 'package:carousel_slider/carousel_controller.dart';
import 'package:cscmobi_app/core/base/base_controller.dart';
import 'package:cscmobi_app/core/values/enums.dart';
import 'package:get/get.dart';

import '../../helper/firebase_helper.dart';

class HowToUseController extends BaseController {

  CarouselSliderController activityController = CarouselSliderController();
  var currentIndex = 0.obs;
  var type = DownloadType.facebook;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    FirebaseHelper.setTrackingScreenName("HowToUseScreen");
    type = Get.arguments["type"];
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

  onChangePage(int value) {
    currentIndex.value = value;
  }

  onSelectNext() {
    if (currentIndex.value == 0) {
      currentIndex++;
      activityController.animateToPage(currentIndex.value);
    } else {
      return;
    }
  }

  onSelectDone() {
    Get.back();
  }

  onSelectBack() {
    Get.back();
  }
}