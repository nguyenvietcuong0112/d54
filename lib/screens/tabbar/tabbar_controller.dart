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
import '../../helper/firebase_helper.dart';
import '../popup_confirm_quit/popup_confirm_quit_controller.dart';
import '../popup_confirm_quit/popup_confirm_quit_page.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';

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

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    Get.put<HomeTabController>(HomeTabController());
    Get.put<HistoryTabController>(HistoryTabController());
    Get.put<SettingTabController>(SettingTabController());

    EasyAds.instance.appLifecycleReactor?.setAllowAppOpenAd(true);

    FirebaseHelper.setTrackingScreenName("HomeScreen");
    requestPermission();
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