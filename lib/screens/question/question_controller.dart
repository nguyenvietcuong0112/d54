import 'package:auto_size_text/auto_size_text.dart';
import 'package:cscmobi_app/core/base/base_controller.dart';
import 'package:cscmobi_app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/app_util.dart';
import '../../helper/admob_ads_manager.dart';
import '../../helper/admod_ads_type.dart';
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
    reloadAds();
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

  reloadAds() {
    if (FirebaseRemoteConfigService.getBoolConfigByKey(FirebaseRemoteConfigService.native_question)) {
      AdmobAdsManager.reloadNativeAdsWithType(NativeAdType.nativeQuestionAd, false, (_nativeAd) {
        if (isClosed) {
          _nativeAd.dispose();
          return;
        }
        isNativeAdLoaded.value = false;
        nativeAd = _nativeAd;
        isNativeAdLoaded.value = true;
      });
      AdmobAdsManager.reloadNativeAdsWithType(NativeAdType.nativeQuestionAltAd, false, (_nativeAd) {
        if (isClosed) {
          _nativeAd.dispose();
          return;
        }
        isNativeAltAdLoaded.value = false;
        nativeAdAlt = _nativeAd;
        isNativeAltAdLoaded.value = true;
      });
    }
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