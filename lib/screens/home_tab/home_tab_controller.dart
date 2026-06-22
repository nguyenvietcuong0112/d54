import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cscmobi_app/core/base/base_controller.dart';
import 'package:cscmobi_app/core/values/enums.dart';
import 'package:cscmobi_app/routes/app_pages.dart';
import 'package:cscmobi_app/screens/download_detail/download_detail_controller.dart';
import 'package:cscmobi_app/screens/tabbar/tabbar_controller.dart';
import 'package:cscmobi_app/screens/url_downloader/url_downloader_controller.dart';
import 'package:cscmobi_app/screens/url_downloader/url_downloader_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lottie/lottie.dart';

import '../../Utils/app_setting.dart';
import '../../helper/admob_ads_manager.dart';
import '../../helper/admod_ads_type.dart';
import '../../helper/firebase_helper.dart';
import '../../helper/firebase_remote_config_service.dart';
import '../download_detail/download_detail_page.dart';

class HomeTabController extends BaseController {
  var title_facebook = "Facebook".obs;
  var title_instagram = "Instagram".obs;
  var title_pinterest = "Pinterest".obs;
  var title_twitter = "Twitter".obs;
  var title_tiktok = "TikTok".obs;

  RxBool isNativeAdLoadingFailed = false.obs;
  RxBool showHomeLoading = false.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    // Load inter_home ad for feature button clicks
    if (FirebaseRemoteConfigService.getBoolConfigByKey(
        FirebaseRemoteConfigService.inter_home)) {
      AdmobAdsManager.loadAdmobInterstitialAdWithType(InterAdType.interHomeAd);
    }
    title_facebook.value = FirebaseRemoteConfigService.getStringConfigByKey(
        FirebaseRemoteConfigService.title_facebook);
    title_instagram.value = FirebaseRemoteConfigService.getStringConfigByKey(
        FirebaseRemoteConfigService.title_instagram);
    title_pinterest.value = FirebaseRemoteConfigService.getStringConfigByKey(
        FirebaseRemoteConfigService.title_pinterest);
    title_twitter.value = FirebaseRemoteConfigService.getStringConfigByKey(
        FirebaseRemoteConfigService.title_twitter);
    title_tiktok.value = FirebaseRemoteConfigService.getStringConfigByKey(
        FirebaseRemoteConfigService.title_tiktok);
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    reloadAds();
    _startHomeLoadingTimer();
  }

  void _startHomeLoadingTimer() {
    if (AppSetting.isPremiumUser.value || AppSetting.isRemoveAds.value) {
      return;
    }
    
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: Lottie.asset(
            'assets/json/loading.json',
            width: 150,
            height: 150,
            fit: BoxFit.contain,
          ),
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.65),
    );

    Timer(const Duration(seconds: 3), () {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
    });
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  reloadAds() {
    isNativeAdLoadingFailed.value = false;
    Timer(const Duration(seconds: 3), () {
      if (!isClosed && !isNativeAdLoaded.value) {
        isNativeAdLoadingFailed.value = true;
      }
    });

    if (FirebaseRemoteConfigService.getBoolConfigByKey(
        FirebaseRemoteConfigService.native_home)) {
      AdmobAdsManager.reloadNativeAdsWithType(
          NativeAdType.nativeHomeMediumAd, false, (_nativeAd) {
        if (isClosed) {
          _nativeAd.dispose();
          return;
        }
        isNativeAdLoadingFailed.value = false;
        isNativeAdLoaded.value = false;
        nativeAd = _nativeAd;
        isNativeAdLoaded.value = true;
      });
    }
  }

  goToScreenWithType(DownloadType type) {
    Get.toWithController(
        controllerBuilder: () => DownloadDetailController(),
        page: () => DownloadDetailPage(),
        arguments: {"type": type});
  }

  // Sử dụng interHomeAd cho tất cả feature buttons trên Home (trừ Settings)
  onSelectFacebook() {
    AdmobAdsManager.showAdmobInterstitialAdWithType(InterAdType.interHomeAd,
        onNextScreen: () async {
      goToScreenWithType(DownloadType.facebook);
    });
  }

  onSelectInstagram() {
    AdmobAdsManager.showAdmobInterstitialAdWithType(InterAdType.interHomeAd,
        onNextScreen: () async {
      goToScreenWithType(DownloadType.instagram);
    });
  }

  onSelectTwitter() {
    AdmobAdsManager.showAdmobInterstitialAdWithType(InterAdType.interHomeAd,
        onNextScreen: () async {
      goToScreenWithType(DownloadType.twitter);
    });
  }

  onSelectTiktok() {
    AdmobAdsManager.showAdmobInterstitialAdWithType(InterAdType.interHomeAd,
        onNextScreen: () async {
      goToScreenWithType(DownloadType.tiktok);
    });
  }

  onSelectURLDownloader({String? validUrl = ""}) {
    AdmobAdsManager.showAdmobInterstitialAdWithType(InterAdType.interHomeAd,
        onNextScreen: () async {
      Get.toWithController(
          controllerBuilder: () => URLDownloaderController(),
          page: () => URLDownloaderPage(),
          arguments: {"type": DownloadType.webview, "url": validUrl});
    });
  }

  onSelectPinterest() {
    AdmobAdsManager.showAdmobInterstitialAdWithType(InterAdType.interHomeAd,
        onNextScreen: () async {
      goToScreenWithType(DownloadType.pinterest);
    });
  }

  onSelectAddUrl() {
    AdmobAdsManager.showAdmobInterstitialAdWithType(InterAdType.interHomeAd,
        onNextScreen: () async {
      goToScreenWithType(DownloadType.addUrl);
    });
  }
}
