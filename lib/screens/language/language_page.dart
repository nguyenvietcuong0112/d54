import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:cscmobi_app/ads/dimens/ad_dimen.dart';
import '../../core/values/app_colors.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/const/ad_id_extension.dart';
import 'language_controller.dart';

class LanguagePage extends GetView<LanguageController> {
  const LanguagePage({super.key});

  @override
  LanguageController get controller => Get.isRegistered<LanguageController>() ? Get.find<LanguageController>() : Get.put(LanguageController());
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              Positioned.fill(
                child: SafeArea(
                  child: Column(
                    children: [
                      buildNavigation(),
                      Flexible(
                        flex: 1,
                        child: buildContent(),
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Obx(() {
                  final bool showStd = controller.showLanguageAd.value;
                  final bool showAlt = controller.showLanguageClickAd.value;
                  final bool isShowAlt = controller.isShowAltAds.value;

                  if (isShowAlt) {
                    return showAlt
                        ? EasyNativeAdCached(
                            key: const ValueKey('language_alt'),
                            factoryId: 'nativeMedia',
                            adId: MyAdIdName.nativeLanguageClick.getId,
                            cacheKey: MyAdIdName.nativeLanguageClick,
                            height: AdDimen.mediumNativeHeight,
                          )
                        : const SizedBox();
                  } else {
                    return showStd
                        ? EasyNativeAdCached(
                            key: const ValueKey('language_std'),
                            factoryId: 'nativeMedia',
                            adId: MyAdIdName.nativeLanguage.getId,
                            cacheKey: MyAdIdName.nativeLanguage,
                            height: AdDimen.mediumNativeHeight,
                          )
                        : const SizedBox();
                  }
                }),
              )
            ],
          ),
        )
    );
  }

  buildContent() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: Obx(() {
              final bool showAd = (controller.isShowAltAds.value && controller.showLanguageClickAd.value) ||
                                  (!controller.isShowAltAds.value && controller.showLanguageAd.value);
              final double bottomPadding = showAd ? (AdDimen.mediumNativeHeight + 10) : 20.0;
              return ListView.builder(
                  itemCount: controller.itemsList.length,
                  scrollDirection: Axis.vertical,
                  padding: EdgeInsets.only(left: 20, right: 20, bottom: bottomPadding, top: 20),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        controller.onSelectItem(index);
                      },
                      child: Obx(() => Container(
                        height: 56,
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: controller.selectedIndex.value == index
                                ? AppColors.main
                                : const Color(0xFF2C2C3E),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                controller.selectedIndex.value == index
                                    ? _buildSelectedRadio()
                                    : _buildUnselectedRadio(),
                                
                                const SizedBox(width: 16),
                                
                                Text(
                                  controller.itemsList[index].title,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: controller.selectedIndex.value == index ? AppColors.black : AppColors.white,
                                      fontSize: 16
                                  ),
                                )
                              ],
                            ),
                            
                            Image.asset(
                              controller.itemsList[index].pngAsset,
                              width: 36,
                              height: 26,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      )),
                    );
                  }
              );
            }),
          ),
          Positioned(
            top: 22,
            right: 20,
            child: Obx(() => !controller.isShowAltAds.value
                ? IgnorePointer(
              ignoring: true,
              child: Container(
                width: 60,
                height: 60,
                color: Colors.transparent,
                child: Center(
                  child: Lottie.asset('assets/json/tap.json'),
                ),
              ),
            ) : const SizedBox()),
          )
        ],
      ),
    );
  }

  buildNavigation() {
    return SizedBox(
      height: 64,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (!controller.isFirstLaunch.value)
            Positioned(
              left: 10,
              child: GestureDetector(
                onTap: () => controller.onSelectBack(),
                child: Container(
                  width: 40,
                  height: 40,
                  color: Colors.transparent,
                  child: const Icon(
                    Icons.arrow_back,
                    color: AppColors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          
          Text(
            "Language".tr,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.white
            ),
          ),
          
          Positioned(
            right: 20,
            child: Obx(() {
              final bool isFirst = controller.isFirstLaunch.value;
              if (controller.selectedIndex.value == 100) {
                return Opacity(
                  opacity: 0.4,
                  child: Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isFirst) ...[
                          const Icon(
                            Icons.check,
                            color: AppColors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 5),
                        ],
                        Text(
                          isFirst ? "Next".tr : "Save".tr,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              if (controller.isShouldShowNext.value) {
                return GestureDetector(
                  onTap: () => controller.onClickNext(),
                  child: Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isFirst) ...[
                          const Icon(
                            Icons.check,
                            color: AppColors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 5),
                        ],
                        Text(
                          isFirst ? "Next".tr : "Save".tr,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                );
              }
            }),
          )
        ],
      ),
    );
  }

  Widget _buildSelectedRadio() {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          width: 2,
          color: AppColors.black,
        ),
      ),
      child: Center(
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildUnselectedRadio() {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          width: 2,
          color: const Color(0xFF6F7084),
        ),
      ),
    );
  }
}
