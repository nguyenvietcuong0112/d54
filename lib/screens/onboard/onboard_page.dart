import 'package:cscmobi_app/core/values/app_colors.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:cscmobi_app/ads/dimens/ad_dimen.dart';
import 'onboard_controller.dart';

class OnboardPage extends GetView<OnboardController> {
  const OnboardPage({super.key});

  @override
  OnboardController get controller =>
      Get.isRegistered<OnboardController>()
          ? Get.find<OnboardController>()
          : Get.put(OnboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: GetBuilder<OnboardController>(
        builder: (_) {
          final steps = controller.getSteps();
          
          if (steps.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.main),
            );
          }

          if (controller.currentIndex.value >= steps.length) {
            controller.currentIndex.value = steps.length - 1;
          }
          if (controller.currentIndex.value < 0) {
            controller.currentIndex.value = 0;
          }

          final currentStep = steps[controller.currentIndex.value];

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: controller.pageController,
                    itemCount: steps.length,
                    onPageChanged: (index) {
                      controller.onChangePage(index);
                    },
                    itemBuilder: (context, index) {
                      final step = steps[index];
                      if (step.fullAd != null) {
                        return _buildFullAdPage(controller, step);
                      } else {
                        return _buildOnboardContent(controller, step);
                      }
                    },
                  ),
                ),
                
                if (currentStep.fullAd == null) ...[
                  _buildBottomControls(controller, steps, currentStep),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOnboardContent(OnboardController controller, OnboardStep step) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenHeight = constraints.maxHeight;
        
        final bool isCornerStyle = step.image.contains("onboard1") || step.image.contains("onboard4");
        
        final double imageWidth = isCornerStyle ? (screenHeight * 0.38).clamp(200.0, 340.0) : double.infinity;
        final double imageHeight = isCornerStyle ? (screenHeight * 0.38).clamp(200.0, 340.0) : screenHeight * 0.65;
        final double topPadding = isCornerStyle ? screenHeight * 0.04 : 0.0;

        return Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: topPadding),
            SizedBox(
              width: imageWidth,
              height: imageHeight,
              child: Center(
                child: Image.asset(
                  step.image,
                  fit: isCornerStyle ? BoxFit.contain : BoxFit.cover,
                  width: imageWidth,
                  height: imageHeight,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                step.title,
                style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.textColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                step.desc,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6F7084),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomControls(OnboardController controller, List<OnboardStep> steps, OnboardStep currentStep) {
    const int totalIntroPages = 4;
    final int introIndex = controller.getIntroIndex(controller.currentIndex.value, steps);
        final bool isCornerStyle = currentStep.image.contains("onboard1") || currentStep.image.contains("onboard4");

    if (isCornerStyle) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            margin: const EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DotsIndicator(
                  dotsCount: totalIntroPages,
                  position: introIndex.toDouble(),
                  decorator: DotsDecorator(
                    color: AppColors.gray2,
                    activeColor: AppColors.main,
                    size: const Size(40, 8),
                    activeSize: const Size(40, 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    spacing: const EdgeInsets.only(right: 10),
                  ),
                ),
                Obx(() {
                  final bool isAdLoading = (introIndex == 0 && controller.isIntro1AdLoading.value) ||
                                           (introIndex == 3 && controller.isIntro4AdLoading.value);
                  if (isAdLoading) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.main, width: 1),
                      ),
                      child: const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.main,
                        ),
                      ),
                    );
                  }
                  return GestureDetector(
                    onTap: () => controller.onSelectNext(steps),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.main, width: 1),
                      ),
                      child: Center(
                        child: Text(
                          controller.getTitleButton(introIndex),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.main,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          // Bottom Native Ad
          if (currentStep.adId.isNotEmpty && currentStep.factoryId.isNotEmpty)
            SizedBox(
              height: AdDimen.mediumNativeHeight,
              child: EasyNativeAd(
                key: ValueKey(currentStep.adId),
                factoryId: currentStep.factoryId,
                adId: currentStep.adId,
                height: AdDimen.mediumNativeHeight,
              ),
            ),
        ],
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dots Indicator
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: DotsIndicator(
              dotsCount: totalIntroPages,
              position: introIndex.toDouble(),
              decorator: DotsDecorator(
                color: AppColors.gray2,
                activeColor: AppColors.main,
                size: const Size(40, 8),
                activeSize: const Size(40, 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                spacing: const EdgeInsets.only(right: 10),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: GestureDetector(
              onTap: () => controller.onSelectNext(steps),
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.main,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    controller.getTitleButton(introIndex),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildFullAdPage(OnboardController controller, OnboardStep step) {
    final steps = controller.getSteps();
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.backgroundColor,
      ),
      child: Stack(
        children: [
          step.fullAd != null
              ? Positioned.fill(
                  child: step.fullAd!.show(),
                )
              : const SizedBox(),
          Positioned(
            right: 20,
            top: 20,
            child: SafeArea(
              child: GestureDetector(
                onTap: () => controller.onSelectNext(steps),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.main,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.main,
                      width: 1,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      CupertinoIcons.arrow_right,
                      color: AppColors.black,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}