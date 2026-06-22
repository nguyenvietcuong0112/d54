import 'dart:async';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cscmobi_app/core/base/base_controller.dart';
import 'package:cscmobi_app/screens/history_tab/history_tab_controller.dart';
import 'package:cscmobi_app/screens/home_tab/home_tab_controller.dart';
import 'package:cscmobi_app/screens/setting_tab/setting_tab_controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../Utils/app_setting.dart';
import '../../helper/admob_ads_manager.dart';
import '../../helper/admod_ads_type.dart';
import '../../helper/firebase_helper.dart';
import '../../helper/firebase_remote_config_service.dart';
import '../popup_confirm_quit/popup_confirm_quit_controller.dart';
import '../popup_confirm_quit/popup_confirm_quit_page.dart';

class TabbarController extends BaseController with GetTickerProviderStateMixin {
  RxInt selectedIndex = 0.obs;
  PageController pageController = PageController(
      keepPage: true,
      initialPage: 0
  );
  late AnimationController borderRadiusAnimationController;
  RxInt tabbarIndex = 0.obs;
  late AnimationController animationController;
  List<Widget> bottomBarPages = [];
  final autoSizeGroup = AutoSizeGroup();

  // Timer để reload banner_home mỗi 15 giây
  Timer? _bannerReloadTimer;
  RxBool isBannerAdLoadingFailed = false.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    Get.put<HomeTabController>(HomeTabController());
    Get.put<HistoryTabController>(HistoryTabController());
    Get.put<SettingTabController>(SettingTabController());

    FirebaseHelper.setTrackingScreenName("HomeScreen");
    requestPermission();
    reloadBannerHome();
    _startBannerReloadTimer();
    borderRadiusAnimationController = AnimationController(
        duration: Duration(milliseconds: 500),
        vsync: this
    );
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    animationController.forward();
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    update();
  }

  @override
  void onClose() {
    super.onClose();
    _bannerReloadTimer?.cancel();
    animationController.dispose();
    borderRadiusAnimationController.dispose();
  }

  requestPermission() async {
    PermissionStatus status = await Permission.notification.request();
    final notificationSettings = await FirebaseMessaging.instance.requestPermission(provisional: true);
    final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    if (apnsToken != null) {
      // APNS token is available, make FCM plugin API requests...
    }
  }

  // banner_home: Collab banner ở dưới cùng màn Home, Download (15s reload 1 lần)
  reloadBannerHome() {
    isBannerAdLoadingFailed.value = false;
    Timer(const Duration(seconds: 3), () {
      if (!isClosed && !isBannerAdLoaded.value) {
        isBannerAdLoadingFailed.value = true;
        update();
      }
    });

    if (FirebaseRemoteConfigService.getBoolConfigByKey(FirebaseRemoteConfigService.banner_home)) {
      AdmobAdsManager.reloadBannerAdWithType(BannerAdType.bannerHome, true, (_bannerAd) {
        if (isClosed) {
          _bannerAd.dispose();
          return;
        }
        isBannerAdLoadingFailed.value = false;
        isBannerAdLoaded.value = false;
        bannerAd = _bannerAd;
        isBannerAdLoaded.value = true;
        update();
      });
    }
  }

  // Timer reload banner mỗi 15 giây
  _startBannerReloadTimer() {
    _bannerReloadTimer?.cancel();
    _bannerReloadTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (isClosed) {
        timer.cancel();
        return;
      }
      // Dispose banner cũ trước khi load mới
      if (bannerAd != null) {
        bannerAd!.dispose();
        bannerAd = null;
        isBannerAdLoaded.value = false;
      }
      reloadBannerHome();
    });
  }



  showBackDialog(BuildContext context) async {
    try {
      var result = await Get.dialog(
          GetBuilder<PopupConfirmQuitController>(
            init: PopupConfirmQuitController(), // Optional: Initialize controller here if needed
            builder: (controller) {
              return PopupConfirmQuitPage();
            },
          ),
          useSafeArea: true,
          barrierDismissible: false,
          arguments: {
            "title": "Exit app".tr,
            "desc": "Are you sure you want to exit the application?".tr,
            "titleButton1": "Yes".tr,
            "titleButton2": "No".tr,
          });
      if (result != null && result["result"] != null && result["result"]) {
        exit(0);
      }
    } catch (e) {}
  }

  onChangeTabbarIndex(index) {
    this.tabbarIndex.value = index;
    if (index != selectedIndex.value) {
      if (index == 0) {
        FirebaseHelper.setTrackingScreenName("HomeTabScreen");
      } else if (index == 1) {
        FirebaseHelper.setTrackingScreenName("DownloadTabScreen");
      } else if (index == 2){
        FirebaseHelper.setTrackingScreenName("SettingTabScreen");
      }
      selectedIndex.value = index;
      pageController.jumpToPage(index);
      update();
    }
  }

}