import 'package:auto_size_text/auto_size_text.dart';
import 'package:cscmobi_app/core/base/base_controller.dart';
import 'package:cscmobi_app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/const/ad_id_extension.dart';

import '../../core/utils/app_util.dart';
import '../../helper/firebase_helper.dart';
import '../../helper/firebase_remote_config_service.dart';
import '../tabbar/tabbar_controller.dart';
import '../tabbar/tabbar_page.dart';

class QuestionController extends BaseController {

  RxBool isShouldShowNext = false.obs;
  List<String> listQuestion = [];
  List<int> listIndexSelected = [];
  RxBool isShowAdsAlt = false.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    initData();
    FirebaseHelper.setTrackingScreenName("QuestionScreen");
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

  initData() {
    listQuestion.add("📶  Watch videos offline".tr);
    listQuestion.add("💾  Save videos for later".tr);
    listQuestion.add("🎵  Download music from videos".tr);
    listQuestion.add("📤  Share with friends".tr);
    listQuestion.add("✂️  Edit or trim videos".tr);
    listQuestion.add("⚡  Fast & simple downloads".tr);
  }


  onSelectBack() {
    Get.back();
  }

  onSelectItem(int index) {
    if (listIndexSelected.contains(index)) {
      listIndexSelected.remove(index);
    } else {
      listIndexSelected.add(index);
    }
    isShouldShowNext.value = listIndexSelected.isNotEmpty;
    if (!isShowAdsAlt.value) {
      isShowAdsAlt.value = true;
    }
    update();
  }

  onSelectNext() {
    AppUtil.saveBool("isNoFirstOpenApp", true);
    // AppUtil.saveString(Constants.kFirstTimeOpenApp, DateTime.now().toIso8601String());
    // Get.offAllNamed(AppRoutes.TABBAR);
    Get.offAllWithController(controllerBuilder: () => TabbarController(), page: () => TabbarPage());
  }
}