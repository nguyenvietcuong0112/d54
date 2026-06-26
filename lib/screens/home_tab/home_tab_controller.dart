import 'dart:async';
import 'package:cscmobi_app/core/base/base_controller.dart';
import 'package:cscmobi_app/core/values/enums.dart';
import 'package:cscmobi_app/routes/app_pages.dart';
import 'package:cscmobi_app/screens/download_detail/download_detail_controller.dart';
import 'package:cscmobi_app/screens/url_downloader/url_downloader_controller.dart';
import 'package:cscmobi_app/screens/url_downloader/url_downloader_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/const/ad_id_extension.dart';
import '../../helper/firebase_remote_config_service.dart';
import '../download_detail/download_detail_page.dart';

class HomeTabController extends BaseController {
  var title_facebook = "Facebook".obs;
  var title_instagram = "Instagram".obs;
  var title_pinterest = "Pinterest".obs;
  var title_twitter = "Twitter".obs;
  var title_tiktok = "TikTok".obs;

    @override
  void onInit() {
    super.onInit();
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
    super.onReady();
    _startHomeLoadingTimer();
  }

  void _startHomeLoadingTimer() {
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

    Timer(const Duration(seconds: 4), () {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
    });
  }

  @override
  void onClose() {
    super.onClose();
  }

  goToScreenWithType(DownloadType type) {
    Get.toWithController(
        controllerBuilder: () => DownloadDetailController(),
        page: () => DownloadDetailPage(),
        arguments: {"type": type});
  }

  _showAdAndNavigate(VoidCallback onDone) {
    final bool showAd = FirebaseRemoteConfigService.getBoolConfigByKey(
        FirebaseRemoteConfigService.inter_home);
    if (showAd) {
      EasyAds.instance.showInterstitialAd(
        Get.context!,
        adId: MyAdIdName.interHomeAd.getId,
        adDissmissed: onDone,
        onFailed: onDone,
      );
    } else {
      onDone();
    }
  }

  // Sử dụng interHomeAd cho tất cả feature buttons trên Home (trừ Settings)
  onSelectFacebook() {
    _showAdAndNavigate(() => goToScreenWithType(DownloadType.facebook));
  }

  onSelectInstagram() {
    _showAdAndNavigate(() => goToScreenWithType(DownloadType.instagram));
  }

  onSelectTwitter() {
    _showAdAndNavigate(() => goToScreenWithType(DownloadType.twitter));
  }

  onSelectTiktok() {
    _showAdAndNavigate(() => goToScreenWithType(DownloadType.tiktok));
  }

  onSelectURLDownloader({String? validUrl = ""}) {
    _showAdAndNavigate(() {
      Get.toWithController(
          controllerBuilder: () => URLDownloaderController(),
          page: () => URLDownloaderPage(),
          arguments: {"type": DownloadType.webview, "url": validUrl});
    });
  }

  onSelectPinterest() {
    _showAdAndNavigate(() => goToScreenWithType(DownloadType.pinterest));
  }

  onSelectAddUrl() {
    _showAdAndNavigate(() => goToScreenWithType(DownloadType.addUrl));
  }
}
