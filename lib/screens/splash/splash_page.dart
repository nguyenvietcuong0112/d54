import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Utils/app_setting.dart';
import '../../core/values/app_colors.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/const/ad_id_extension.dart';
import 'splash_controller.dart';

class SplashPage extends GetView<SplashController> {
  @override
  SplashController get controller => Get.isRegistered<SplashController>() ? Get.find<SplashController>() : Get.put(SplashController());
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFFED464),
        resizeToAvoidBottomInset: false,
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                      color: Color(0xFF1E1E2A)
                  ),
                ),
              ),
              Positioned.fill(
                child: SafeArea(
                  child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/png/splash_thumb.png',
                            width: 150,
                            height: 150,
                          ),
                          Container(
                            transform: Matrix4.translationValues(0.0, 0, 0.0),
                            child: Text(
                              "HD Video Downloader & Player",
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 150,
                          ),
                        ],
                      )
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    SafeArea(
                      top: false,
                      bottom: true,
                      child: Column(
                        children: [
                          const Text(
                            "This action can contain adversting",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF686868)
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Obx(() => Container(
                            padding: EdgeInsets.only(left: 20, right: 20),
                            child: LinearProgressIndicator(
                              value: controller.percentLoading.value,
                              color: AppColors.main,
                              minHeight: 10,
                              borderRadius: BorderRadius.circular(10),
                              backgroundColor: Color(0xFFEAEAEA),
                            ),
                          ))
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                          color: Colors.white
                      ),
                      child: EasyBannerAd(
                        adId: MyAdIdName.bannerSplash.getId,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
