


import 'package:cscmobi_app/core/values/app_colors.dart';
import 'package:cscmobi_app/core/widget/button_back.dart';
import 'package:cscmobi_app/screens/setting_tab/setting_tab_controller.dart';
import 'package:cscmobi_app/screens/tabbar/tabbar_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Utils/app_setting.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/const/ad_id_extension.dart';
import '../../helper/firebase_remote_config_service.dart';
import 'package:cscmobi_app/ads/dimens/ad_dimen.dart';

class SettingTabPage extends GetView<SettingTabController> {
  @override
  SettingTabController get controller => Get.isRegistered<SettingTabController>() ? Get.find<SettingTabController>() : Get.put(SettingTabController());

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
        child: Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: SafeArea(
            bottom: false,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                children: [
                  buildNavigation(),
                  Expanded(
                    child: buildContent(),
                  ),
                ],
              ),
            ),
          ),
        ),
        onWillPop: () => controller.onSelectBack()
    );
  }

  buildContent() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.only(left: 16, right: 16, top: 16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                controller.onSelectLanguage();
              },
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.backgroundItemColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: EdgeInsets.only(left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/png/setting_language.png",
                      width: 32,
                      height: 32,
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Text(
                      "Language".tr,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            GestureDetector(
              onTap: () {
                controller.onSelectShareApp();
              },
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.backgroundItemColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: EdgeInsets.only(left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/png/setting_share_app.png",
                      width: 32,
                      height: 32,
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Text(
                      "Share app".tr,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            GestureDetector(
              onTap: () {
                controller.onSelectRateApp();
              },
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.backgroundItemColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: EdgeInsets.only(left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/png/setting_rate_app.png",
                      width: 32,
                      height: 32,
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Text(
                      "Rate app".tr,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            GestureDetector(
              onTap: () {
                controller.onSelectPrivacy();
              },
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.backgroundItemColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: EdgeInsets.only(left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/png/setting_policy.png",
                      width: 32,
                      height: 32,
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Text(
                      "Privacy policy".tr,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            GestureDetector(
              onTap: () {
                controller.onSelectVersion();
              },
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.backgroundItemColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: EdgeInsets.only(left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/png/setting_version.png",
                          width: 32,
                          height: 32,
                        ),
                        SizedBox(
                          width: 16,
                        ),
                        Text(
                          "Version".tr,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor
                          ),
                        )
                      ],
                    ),
                    Obx(() => Text(
                      controller.appVersion.value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      ),
                    )),
                  ],
                ),
              ),
            ),
             FirebaseRemoteConfigService.getBoolConfigByKey(FirebaseRemoteConfigService.native_home)
                ? EasyNativeAd(
                    key: const ValueKey('settings_bottom_ad'),
                    factoryId: 'nativeMedia',
                    adId: MyAdIdName.nativeHomeAd.getId,
                    height: AdDimen.mediumNativeHeight,
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  buildNavigation() {
    return Container(
      height: 64,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.only(left: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ButtonBack(
                    onTap: () {
                      controller.onSelectBack();
                    },
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Text(
                    "Settings".tr,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textColor
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}