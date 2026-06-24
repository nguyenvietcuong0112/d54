import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:cscmobi_app/ads/dimens/ad_dimen.dart';
import '../../core/values/app_colors.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/const/ad_id_extension.dart';
import '../../utils/app_setting.dart';
import 'language_controller.dart';

class LanguagePage extends GetView<LanguageController> {
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
                  final bool isShowAlt = controller.isShowAltAds.value;
                  return isShowAlt
                      ? EasyNativeAd(
                          key: const ValueKey('language_alt'),
                          factoryId: 'nativeMedia',
                          adId: MyAdIdName.nativeLanguageClick.getId,
                          height: AdDimen.mediumNativeHeight,
                        )
                      : EasyNativeAd(
                          key: const ValueKey('language_std'),
                          factoryId: 'nativeMedia',
                          adId: MyAdIdName.nativeLanguage.getId,
                          height: AdDimen.mediumNativeHeight,
                        );
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
            child: ListView.builder(
                itemCount: controller.itemsList.length,
                scrollDirection: Axis.vertical,
                padding: const EdgeInsets.only(left: 20, right: 20, bottom:  AdDimen.mediumNativeHeight + 10, top: 20),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      controller.onSelectItem(index);
                    },
                    child: Obx(() => Container(
                      height: 56, // Tăng chiều cao lên 56px cho sang trọng hơn
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12), // Bo góc 12px theo mockup
                          color: controller.selectedIndex.value == index
                              ? AppColors.main
                              : const Color(0xFF2C2C3E), // Màu thẻ tối unselected
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Đẩy Flag sang mép phải
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // 1. Radio Button nằm bên TRÁI
                              controller.selectedIndex.value == index
                                  ? _buildSelectedRadio()
                                  : _buildUnselectedRadio(),
                              
                              const SizedBox(width: 16),
                              
                              // 2. Chữ hiển thị ngôn ngữ
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
                          
                          // 3. Quốc kỳ (Flag) hiển thị lại ở bên PHẢI
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
            ),
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

  /// Cấu trúc App Navigation Bar chuẩn theo Mockup (Tiêu đề căn giữa, nút Save bên phải)
  buildNavigation() {
    return SizedBox(
      height: 64,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Nút Back (chỉ hiển thị nếu không phải lần đầu mở app)
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
          
          // 2. Tiêu đề "Language" căn chính giữa màn hình
          Text(
            "Language".tr,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.white
            ),
          ),
          
          // 3. Nút hành động ở góc phải (Chữ thuần không có viền hộp - Next hoặc Save)
          Positioned(
            right: 20,
            child: Obx(() {
              if (controller.selectedIndex.value == 100) return const SizedBox();
              
              if (controller.isShouldShowNext.value) {
                final bool isFirst = controller.isFirstLaunch.value;
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

  /// Helper Widget: Vẽ nút Radio trạng thái Đã chọn (Màu đen nằm trong thẻ Lime)
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

  /// Helper Widget: Vẽ nút Radio trạng thái Chưa chọn (Đường viền xám mỏng)
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
