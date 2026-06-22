


import 'package:cscmobi_app/core/values/app_colors.dart';
import 'package:cscmobi_app/screens/question/question_controller.dart';
import 'package:cscmobi_app/screens/tabbar/tabbar_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Utils/app_setting.dart';
import '../../helper/admob_helper.dart';

class QuestionPage extends GetView<QuestionController> {
  @override
  QuestionController get controller => Get.isRegistered<QuestionController>() ? Get.find<QuestionController>() : Get.put(QuestionController());
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  children: [
                    buildNavigation(),
                    Expanded(
                      child: buildContent(),
                    )
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Obx(() =>
              (controller.isNativeAdLoaded.value && controller.nativeAd != null
                  && !AppSetting.isPremiumUser.value
                  && !controller.isShowAdsAlt.value)
                  ? SizedBox(
                child: AdmobAdHelper().getNativeAdWidgetMedium(ad: controller.nativeAd!),
              ) :
              Container()),
            ),
          ),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: Obx(() => controller.isNativeAltAdLoaded.value
                    && controller.nativeAdAlt != null
                    && !AppSetting.isPremiumUser.value
                    && controller.isShowAdsAlt.value
                    ? SizedBox(
                  child: AdmobAdHelper().getNativeAdWidgetMedium(ad: controller.nativeAdAlt!),
                ) :
                Container()
                ),
              )
          )
        ],
      ),
    );
  }

  buildContent() {
    return GetBuilder<QuestionController>(
      builder: (builder) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.only(left: 20, right: 20, top: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "What do you download videos for?".tr,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColor
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 30,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: controller.listQuestion.length,
                  padding: EdgeInsets.only(bottom: 230),
                  itemBuilder: (context, index) {
                    bool isSelected = controller.listIndexSelected.contains(index);
                    return GestureDetector(
                      onTap: () {
                        controller.onSelectItem(index);
                      },
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: 10),
                        padding: EdgeInsets.only(left: 20, right: 20),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: isSelected
                                ? AppColors.main
                                : Color(0xFF2c2c3e),
                            border: Border.all(
                              width: 1,
                              color: isSelected
                                  ? AppColors.main
                                  : Color(0xFFFB8B02).withOpacity(0.2),
                            )
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  controller.listQuestion[index],
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: isSelected ? AppColors.black : AppColors.white,
                                      fontSize: 16
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }

  buildNavigation() {
    return Container(
      height: 64,
      width: double.infinity,
      child: Stack(
        children: [
          Obx(() => controller.isShouldShowNext.value
              ? Positioned(
            right: 20,
            bottom: 0,
            top: 0,
            child: Center(
              child: GestureDetector(
                  onTap: () {
                    controller.onSelectNext();
                  },
                  child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.main,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Next".tr,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.black
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppColors.black,
                            size: 14,
                          )
                        ],
                      )
                  ),
              ),
            ),
          ) : Positioned(
            right: 20,
            bottom: 0,
            top: 0,
            child: Center(
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    color: Color(0xFFEAEAEA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Next".tr,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blackText
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppColors.blackText,
                        size: 14,
                      )
                    ],
                  )
              ),
            ),
            // child: Center(
            //     child: Container(
            //         height: 40,
            //         width: 52,
            //         decoration: BoxDecoration(
            //           color: Color(0xFFEAEAEA),
            //           borderRadius: BorderRadius.circular(15),
            //         ),
            //         child: Center(
            //           child: Icon(
            //             Icons.keyboard_arrow_right_rounded,
            //             color: AppColors.blackText,
            //             size: 24,
            //           ),
            //         )
            //     )
            // ),
          )),
        ],
      ),
    );
  }
}