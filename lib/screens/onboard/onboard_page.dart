import 'package:carousel_slider/carousel_slider.dart';
import 'package:cscmobi_app/core/values/app_colors.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../Utils/app_setting.dart';
import '../../helper/admob_helper.dart';
import 'onboard_controller.dart';

class OnboardPage extends GetView<OnboardController> {
  @override
  OnboardController get controller => Get.isRegistered<OnboardController>() ? Get.find<OnboardController>() : Get.put(OnboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: GetBuilder<OnboardController>(
        builder: (_) {
          return Container(
              width: double.infinity,
              height: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                      child: CarouselSlider.builder(
                        itemCount: 6, // 4 màn hình Intro + 2 màn Full Native Ad xen kẽ
                        options: CarouselOptions(
                          aspectRatio: 1.0,
                          height: double.infinity,
                          enableInfiniteScroll: false,
                          autoPlay: false,
                          viewportFraction: 1,
                          onPageChanged: (index, reason) {
                            controller.onChangePage(index);
                          },
                        ),
                        carouselController: controller.activityController,
                        itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
                          // 1. Giao diện trang quảng cáo Full Native (Trang 1 và 4)
                          if (itemIndex == 1) {
                            return _buildFullAdPage(
                              controller,
                              shouldShowAd: controller.shouldShowAdsFull1.value,
                              nativeAd: controller.nativeOnboardFull1,
                            );
                          }
                          if (itemIndex == 4) {
                            return _buildFullAdPage(
                              controller,
                              shouldShowAd: controller.shouldShowAdsFull2.value,
                              nativeAd: controller.nativeOnboardFull2,
                            );
                          }

                          // 2. Giao diện trang hướng dẫn standard (Trang 0, 2, 3, 5)
                          final bool showSwipe = (itemIndex == 2 || itemIndex == 3);
                          final bool showAdOffset = (itemIndex == 0 && controller.nativeAd != null && !AppSetting.isPremiumUser.value && controller.isNativeAdLoaded.value) ||
                              (itemIndex == 5 && controller.nativeAdAlt != null && !AppSetting.isPremiumUser.value && controller.isNativeAltAdLoaded.value);

                          return _buildOnboardContent(
                            controller,
                            showSwipe: showSwipe,
                            showAdOffset: showAdOffset,
                          );
                        },
                      )
                  ),
                  
                  // 3. Phần hiển thị quảng cáo Native Medium ở dưới đáy màn hình (chỉ ở Trang 0 và Trang 5)
                  Positioned(
                    left: 0,
                    bottom: 0,
                    right: 0,
                    child: Column(
                      children: [
                        (controller.currentIndex.value == 0
                            && controller.isNativeAdLoaded.value
                            && controller.nativeAd != null
                            && !AppSetting.isPremiumUser.value
                            && !controller.isShowingAdsFull1.value
                            && !controller.isShowingAdsFull2.value)
                            ? Container(
                          child: AdmobAdHelper().getNativeAdWidgetMedium(ad: controller.nativeAd!),
                        ) : SizedBox(),
                        (controller.currentIndex.value == 5
                            && controller.isNativeAltAdLoaded.value
                            && controller.nativeAdAlt != null
                            && !AppSetting.isPremiumUser.value
                            && !controller.isShowingAdsFull1.value
                            && !controller.isShowingAdsFull2.value)
                            ? AdmobAdHelper().getNativeAdWidgetMedium(ad: controller.nativeAdAlt!) :
                        SizedBox()
                      ],
                    ),
                  )
                ],
              )
          );
        },
      ),
    );
  }

  /// Helper Widget: Xây dựng giao diện trang nội dung Hướng dẫn chuẩn Responsive UI (LayoutBuilder)
  Widget _buildOnboardContent(OnboardController controller, {required bool showSwipe, required bool showAdOffset}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenHeight = constraints.maxHeight;
        
        // 3. Phân biệt kiểu nút bấm và hình ảnh CỐ ĐỊNH theo trang (0 và 3 là Intro 1 & 4, 1 và 2 là Intro 2 & 3)
        final int currentTab = controller.currentTabOnboard.value;
        final bool isCornerStyle = (currentTab == 0 || currentTab == 3);

        // 1. Tỉ lệ thuận kích thước ảnh: Cực kỳ an toàn
        // Intro 1, 4 (isCornerStyle = true): Ảnh bo tròn vuông ở giữa (max 340px)
        // Intro 2, 3 (isCornerStyle = false): Ảnh full hoàn toàn chiều ngang (double.infinity), chiều cao chiếm đúng 70% (0.7) màn hình
        final double imageWidth = isCornerStyle ? (screenHeight * 0.38).clamp(200.0, 340.0) : double.infinity;
        final double imageHeight = isCornerStyle ? (screenHeight * 0.38).clamp(200.0, 340.0) : screenHeight * 0.70;
        
        // 2. Tỉ lệ khoảng đệm phía trên:
        // Intro 1, 4 có khoảng đệm an toàn. Intro 2, 3 bắt đầu từ sát mép trên cùng (0px) để ảnh hiển thị tràn màn hình
        final double topPadding = isCornerStyle 
            ? (showAdOffset ? (screenHeight * 0.015) : (screenHeight * 0.08))
            : 0.0;

        return Stack(
          children: [
            Positioned.fill(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: topPadding),
                    
                    Container(
                      width: imageWidth,
                      height: imageHeight,
                      child: Center(
                        child: Image.asset(
                          controller.getThumb(),
                          fit: BoxFit.cover,
                          width: imageWidth,
                          height: imageHeight,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            controller.getTitle(),
                            style: TextStyle(
                                fontSize: 18,
                                color: AppColors.textColor,
                                fontWeight: FontWeight.w500
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            controller.getDesc(),
                            style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6F7084),
                                fontWeight: FontWeight.w500
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          )
                        ],
                      ),
                    ),
                    
                    // Điểm mấu chốt: Trong Intro 2 và 3, DotsIndicator nằm ngay sát dưới Description với khoảng cách tỉ lệ đẹp
                    if (!isCornerStyle) ...[
                      SizedBox(height: (screenHeight * 0.035).clamp(16.0, 32.0)),
                      DotsIndicator(
                        dotsCount: controller.totalPage.value, 
                        position: controller.currentTabOnboard.value.toDouble(),
                        decorator: DotsDecorator(
                            color: AppColors.gray2,
                            activeColor: AppColors.main,
                            size: const Size(40, 8),
                            activeSize: const Size(40, 8), // Kéo dài dots indicator active hơn (36px)
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            spacing: const EdgeInsets.only(right: 10)
                        ),
                      ),
                    ],

                    Flexible(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (isCornerStyle) ...[
                            // Giao diện có ad (Intro 1 & 4): Dots và nút Next viền mảnh nằm chung dòng sát Ad chân trang chuẩn ảnh mẫu
                            Container(
                              height: 44,
                              padding: const EdgeInsets.only(left: 20, right: 20),
                              margin: const EdgeInsets.only(bottom: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  DotsIndicator(
                                    dotsCount: controller.totalPage.value,
                                    position: controller.currentTabOnboard.value.toDouble(),
                                    decorator: DotsDecorator(
                                        color: AppColors.gray2,
                                        activeColor: AppColors.main,
                                        size: const Size(40, 8),
                                        activeSize: const Size(40, 8), // Kéo dài dots indicator active hơn (36px)
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                        activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                        spacing: const EdgeInsets.only(right: 10)
                                    ),
                                  ),
                                  Obx(() {
                                    final bool isLoading1 = (controller.currentTabOnboard.value == 0 && controller.isIntro1AdLoading.value);
                                    final bool isLoading4 = (controller.currentTabOnboard.value == 3 && controller.isIntro4AdLoading.value);

                                    if (isLoading1 || isLoading4) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: AppColors.main,
                                            width: 1,
                                          ),
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
                                      onTap: () => controller.onSelectNext(),
                                      child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.transparent, // Nền trong suốt
                                            borderRadius: BorderRadius.circular(10), // Bo góc nhẹ
                                            border: Border.all(
                                              color: AppColors.main, // Viền vàng chanh mảnh tinh tế
                                              width: 1,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              controller.getTitleButton(controller.currentTabOnboard.value),
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColors.main // Màu chữ vàng chanh trùng màu viền, không icon
                                              ),
                                            ),
                                          )
                                      ),
                                    );
                                  })
                                ],
                              ),
                            )
                          ] else ...[
                            // Giao diện không ad (Intro 2 & 3): Nút Next to bản đặc màu độc lập sát đáy màn hình chuẩn ảnh mẫu
                            GestureDetector(
                              onTap: () => controller.onSelectNext(),
                              child: Container(
                                width: double.infinity,
                                height: 48,
                                margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                                decoration: BoxDecoration(
                                  color: AppColors.main,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    controller.getTitleButton(controller.currentTabOnboard.value),
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.black // Đổi màu chữ nút bấm đặc sang màu Đen
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ]
                        ],
                      ),
                    ),
                    if (showAdOffset)
                      const SizedBox(height: 230)
                  ],
                ),
              ),
            ),
            // if (showSwipe)
            //   Positioned(
            //     bottom: 100,
            //     left: 0,
            //     right: 0,
            //     child: Container(
            //       width: double.infinity,
            //       child: Column(
            //         children: [
            //           Container(
            //             width: 70,
            //             height: 70,
            //             child: Center(
            //               child: Lottie.asset('assets/json/swipe_left_black.json'),
            //             ),
            //           ),
            //           Container(
            //             transform: Matrix4.translationValues(0.0, 0.0, 0.0),
            //             child: Text(
            //               "Swipe".tr,
            //               style: TextStyle(
            //                   fontSize: 16,
            //                   fontWeight: FontWeight.w500,
            //                   color: AppColors.blackText
            //               ),
            //             ),
            //           )
            //         ],
            //       ),
            //     ),
            //   )
          ],
        );
      },
    );
  }

  /// Helper Widget: Xây dựng giao diện trang quảng cáo Full Native xen kẽ
  Widget _buildFullAdPage(OnboardController controller, {required bool shouldShowAd, required var nativeAd}) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.backgroundColor,
      ),
      child: Stack(
        children: [
          shouldShowAd && nativeAd != null
              ? Positioned.fill(
            child: AdmobAdHelper().getNativeAdWidgetFull(ad: nativeAd),
          ) : const SizedBox(),
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => controller.onSelectNext(),
                  child: SafeArea(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: AppColors.main,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.main,
                            width: 1,
                          )
                      ),
                      margin: const EdgeInsets.only(right: 20, top: 30),
                      child: const Center(
                        child: Icon(
                          CupertinoIcons.arrow_right,
                          color: AppColors.black,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}