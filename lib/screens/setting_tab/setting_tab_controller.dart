import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cscmobi_app/core/base/base_controller.dart';
import 'package:cscmobi_app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/utils/app_util.dart';
import '../../core/values/constants.dart';
import '../../helper/admob_ads_manager.dart';
import '../../helper/admod_ads_type.dart';
import '../../helper/firebase_helper.dart';
import '../../helper/firebase_remote_config_service.dart';
import '../language/language_controller.dart';
import '../language/language_page.dart';
import '../popup_rating/popup_rating_controller.dart';
import '../popup_rating/popup_rating_page.dart';

class SettingTabController extends BaseController {

  var appVersion = "".obs;
  var deviceId = "";
  var countTapAbout = 0;

  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();
    appVersion.value = await AppUtil().getAppVersion();
    reloadAds();
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose

  }

  reloadAds() {
    if (FirebaseRemoteConfigService.getBoolConfigByKey(FirebaseRemoteConfigService.native_home)) {
      AdmobAdsManager.reloadNativeAdsWithType(NativeAdType.nativeHomeAd, true, (_nativeAd) {
        if (isClosed) {
          _nativeAd.dispose();
          return;
        }
        isNativeAdLoaded.value = false;
        nativeAd = _nativeAd;
        isNativeAdLoaded.value = true;
        update();
      });
    }
  }

  onSelectBack() {
    Get.back();
  }

  onSelectMoreApp() {
    final url = Uri.parse(
      Platform.isAndroid
          ? "https://play.google.com/store/apps/details?id=com.video.downloader.fastsave"
          : "",
    );
    launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  }

  onSelectLanguage() {
    Get.toWithController(controllerBuilder: () => LanguageController(), page: () => LanguagePage());
  }

  onSelectShareApp() {
    var linkShare = "";
    if (Platform.isAndroid) {
      linkShare = "https://play.google.com/store/apps/details?id=com.video.downloader.fastsave";
    }
    if (Platform.isIOS) {
      linkShare = "";
    }
    Share.share(linkShare);
  }

  onSelectRateApp() async {
    var result = await Get.dialog(GetBuilder<PopupRatingController>(
      init: PopupRatingController(), // Optional: Initialize controller here if needed
      builder: (controller) {
        return PopupRatingPage();
      },
    ),arguments: {},
      useSafeArea: false,
    );
    if (result != null) {
      AppUtil.showNormalToast("Thank you for your review".tr);
    }
  }

  onSelectPrivacy() async{
    final Uri url = Uri.parse(Constants.privacy);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  onSelectVersion() async {
    countTapAbout += 1;
    if (countTapAbout == 5) {
      await Clipboard.setData(ClipboardData(text: await AppUtil().getDeviceId()));
      countTapAbout = 0;
      AppUtil.showNormalToast("Đã copy Device Id");
    } else {
      var appVersion = await AppUtil().getAppVersion();
      var androidAppVersion = FirebaseRemoteConfigService.getStringConfigByKey(FirebaseRemoteConfigService.android_app_version);
      if (androidAppVersion.compareTo(appVersion) >= 0) {
        final url = Uri.parse(
          Platform.isAndroid
              ? "https://play.google.com/store/apps/details?id=com.video.downloader.fastsave"
              : "",
        );
        launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      } else {
        AppUtil.showNormalToast("Latest version".tr);
      }
    }
  }
}