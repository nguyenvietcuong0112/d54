

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cscmobi_app/core/values/app_colors.dart';
import 'package:cscmobi_app/core/values/enums.dart';
import 'package:cscmobi_app/screens/how_to_use/how_to_use_controller.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HowToUsePage extends GetView<HowToUseController> {
  @override
  HowToUseController get controller => Get.isRegistered<HowToUseController>() ? Get.find<HowToUseController>() : Get.put(HowToUseController());

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
    );
  }

  buildContent() {
    var widget = buildHelpFacebook();
    if (controller.type == DownloadType.instagram) {
      widget = buildHelpInstagram();
    } else if (controller.type == DownloadType.twitter) {
      widget = buildHelpTwitter();
    } else if (controller.type == DownloadType.pinterest) {
      widget = buildHelpPinterest();
    } else if (controller.type == DownloadType.facebook) {
      widget = buildHelpFacebook();
    } else {
      widget = buildHelpAddUrl();
    }
    return Container(
      width: double.infinity,
      height: double.infinity,
      margin: EdgeInsets.only(left: 20, right: 20),
      child: widget,
    );
  }

  buildHelpAddUrl() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: CarouselSlider.builder(
          itemCount: 4,
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
            var urlImage = "assets/png/help_url1.png";
            if (itemIndex == 1) {
              urlImage = "assets/png/help_url2.png";
            } else if (itemIndex == 2) {
              urlImage = "assets/png/help_url3.png";
            } else if (itemIndex == 3) {
              urlImage = "assets/png/help_url4.png";
            }
            var title = "Copy the link from your browser and paste it into the app’s URL bar".tr;
            if (itemIndex == 1) {
              title = "Click the download button to start downloading".tr;
            } else if (itemIndex == 2) {
              title = "Choose the video resolution you want and start the download".tr;
            } else if (itemIndex == 3) {
              title = "Easily play and manage downloaded videos in the built-in player".tr;
            }
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: AppColors.backgroundItemColor,
                      borderRadius: BorderRadius.circular(16)
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                                color: AppColors.main,
                                shape: BoxShape.circle
                            ),
                            child: Center(
                              child: Text(
                                "${itemIndex + 1}",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textColor
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                              child: Text(
                                title.tr,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textColor
                                ),
                              )
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      AspectRatio(
                        aspectRatio: 348/180,
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          child: Image.asset(
                            urlImage,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Obx(() => DotsIndicator(
                  dotsCount: 4,
                  position: controller.currentIndex.value.toDouble(),
                  decorator: DotsDecorator(
                      color: AppColors.gray2,
                      activeColor: AppColors.main,
                      size: Size(12, 8),
                      activeSize: Size(12, 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      spacing: EdgeInsets.only(right: 10)
                  ),
                )),
                const SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () => itemIndex == 3 ? controller.onSelectDone() : controller.onSelectNext(),
                  child: Container(
                    width: double.infinity,
                    height: 44,
                    decoration: BoxDecoration(
                        color: AppColors.main,
                        borderRadius: BorderRadius.circular(26)
                    ),
                    child: Center(
                      child: Text(
                        itemIndex == 3 ? "Got it".tr : "Next".tr,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor
                        ),
                      ),
                    ),
                  ),
                )
              ],
            );
          }
      ),
    );
  }

  buildHelpTwitter() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: CarouselSlider.builder(
          itemCount: 2,
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
            if (itemIndex == 1) {
              return Column(
                children: [
                  Text(
                    "Method ".tr + "${itemIndex + 1}",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: AppColors.backgroundItemColor,
                        borderRadius: BorderRadius.circular(16)
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                  color: AppColors.main,
                                  shape: BoxShape.circle
                              ),
                              child: Center(
                                child: Text(
                                  "1",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textColor
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Expanded(
                                child: Text(
                                  "Open “X” and tap “Copy link”".tr,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.textColor
                                  ),
                                )
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        AspectRatio(
                          aspectRatio: 348/180,
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            child: Image.asset(
                              "assets/png/help_twitter2.png",
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: AppColors.backgroundItemColor,
                        borderRadius: BorderRadius.circular(16)
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                  color: AppColors.main,
                                  shape: BoxShape.circle
                              ),
                              child: Center(
                                child: Text(
                                  "2",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textColor
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Expanded(
                                child: Text(
                                  "Open “Video Downloader”".tr,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.textColor
                                  ),
                                )
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        AspectRatio(
                          aspectRatio: 348/180,
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            child: Image.asset(
                              "assets/png/help_app_download.png",
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Obx(() => DotsIndicator(
                    dotsCount: 2,
                    position: controller.currentIndex.value.toDouble(),
                    decorator: DotsDecorator(
                        color: AppColors.gray2,
                        activeColor: AppColors.main,
                        size: Size(12, 8),
                        activeSize: Size(12, 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        spacing: EdgeInsets.only(right: 10)
                    ),
                  )),
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () => controller.onSelectDone(),
                    child: Container(
                      width: double.infinity,
                      height: 44,
                      decoration: BoxDecoration(
                          color: AppColors.main,
                          borderRadius: BorderRadius.circular(26)
                      ),
                      child: Center(
                        child: Text(
                          "Got it".tr,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              );
            }
            return Column(
              children: [
                Text(
                  "Method ".tr + "${itemIndex + 1}",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: AppColors.backgroundItemColor,
                      borderRadius: BorderRadius.circular(16)
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                                color: AppColors.main,
                                shape: BoxShape.circle
                            ),
                            child: Center(
                              child: Text(
                                "1",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textColor
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                              child: Text(
                                "Open “X” and click “Share to”".tr,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textColor
                                ),
                              )
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      AspectRatio(
                        aspectRatio: 348/180,
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          child: Image.asset(
                            "assets/png/help_twitter1.png",
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: AppColors.backgroundItemColor,
                      borderRadius: BorderRadius.circular(16)
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                                color: AppColors.main,
                                shape: BoxShape.circle
                            ),
                            child: Center(
                              child: Text(
                                "2",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textColor
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                              child: Text(
                                "Click “Video Downloader”".tr,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textColor
                                ),
                              )
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      AspectRatio(
                        aspectRatio: 348/180,
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          child: Image.asset(
                            "assets/png/help_app_download.png",
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Obx(() => DotsIndicator(
                  dotsCount: 2,
                  position: controller.currentIndex.value.toDouble(),
                  decorator: DotsDecorator(
                      color: AppColors.gray2,
                      activeColor: AppColors.main,
                      size: Size(12, 8),
                      activeSize: Size(12, 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      spacing: EdgeInsets.only(right: 10)
                  ),
                )),
                const SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () => controller.onSelectNext(),
                  child: Container(
                    width: double.infinity,
                    height: 44,
                    decoration: BoxDecoration(
                        color: AppColors.main,
                        borderRadius: BorderRadius.circular(26)
                    ),
                    child: Center(
                      child: Text(
                        "Next".tr,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor
                        ),
                      ),
                    ),
                  ),
                )
              ],
            );
          }
      ),
    );
  }

  buildHelpPinterest() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: CarouselSlider.builder(
          itemCount: 2,
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
            if (itemIndex == 1) {
              return Column(
                children: [
                  Text(
                    "Method ".tr + "${itemIndex + 1}",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: AppColors.backgroundItemColor,
                        borderRadius: BorderRadius.circular(16)
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                  color: AppColors.main,
                                  shape: BoxShape.circle
                              ),
                              child: Center(
                                child: Text(
                                  "1",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textColor
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Expanded(
                                child: Text(
                                  "Open “Pinterest” and tap “Copy link”".tr,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.textColor
                                  ),
                                )
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        AspectRatio(
                          aspectRatio: 348/180,
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            child: Image.asset(
                              "assets/png/help_pinterest2.png",
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: AppColors.backgroundItemColor,
                        borderRadius: BorderRadius.circular(16)
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                  color: AppColors.main,
                                  shape: BoxShape.circle
                              ),
                              child: Center(
                                child: Text(
                                  "2",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textColor
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Expanded(
                                child: Text(
                                  "Open “Video Downloader”".tr,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.textColor
                                  ),
                                )
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        AspectRatio(
                          aspectRatio: 348/180,
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            child: Image.asset(
                              "assets/png/help_app_download.png",
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Obx(() => DotsIndicator(
                    dotsCount: 2,
                    position: controller.currentIndex.value.toDouble(),
                    decorator: DotsDecorator(
                        color: AppColors.gray2,
                        activeColor: AppColors.main,
                        size: Size(12, 8),
                        activeSize: Size(12, 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        spacing: EdgeInsets.only(right: 10)
                    ),
                  )),
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () => controller.onSelectDone(),
                    child: Container(
                      width: double.infinity,
                      height: 44,
                      decoration: BoxDecoration(
                          color: AppColors.main,
                          borderRadius: BorderRadius.circular(26)
                      ),
                      child: Center(
                        child: Text(
                          "Got it".tr,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              );
            }
            return Column(
              children: [
                Text(
                  "Method ".tr + "${itemIndex + 1}",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: AppColors.backgroundItemColor,
                      borderRadius: BorderRadius.circular(16)
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                                color: AppColors.main,
                                shape: BoxShape.circle
                            ),
                            child: Center(
                              child: Text(
                                "1",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textColor
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                              child: Text(
                                "Open “Pinterest” and tap “Share to”".tr,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textColor
                                ),
                              )
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      AspectRatio(
                        aspectRatio: 348/180,
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          child: Image.asset(
                            "assets/png/help_pinterest1.png",
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: AppColors.backgroundItemColor,
                      borderRadius: BorderRadius.circular(16)
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                                color: AppColors.main,
                                shape: BoxShape.circle
                            ),
                            child: Center(
                              child: Text(
                                "2",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textColor
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                              child: Text(
                                "Click “Video Downloader”".tr,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textColor
                                ),
                              )
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      AspectRatio(
                        aspectRatio: 348/180,
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          child: Image.asset(
                            "assets/png/help_app_download.png",
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Obx(() => DotsIndicator(
                  dotsCount: 2,
                  position: controller.currentIndex.value.toDouble(),
                  decorator: DotsDecorator(
                      color: AppColors.gray2,
                      activeColor: AppColors.main,
                      size: Size(12, 8),
                      activeSize: Size(12, 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      spacing: EdgeInsets.only(right: 10)
                  ),
                )),
                const SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () => controller.onSelectNext(),
                  child: Container(
                    width: double.infinity,
                    height: 44,
                    decoration: BoxDecoration(
                        color: AppColors.main,
                        borderRadius: BorderRadius.circular(26)
                    ),
                    child: Center(
                      child: Text(
                        "Next".tr,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor
                        ),
                      ),
                    ),
                  ),
                )
              ],
            );
          }
      ),
    );
  }

  buildHelpInstagram() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: CarouselSlider.builder(
          itemCount: 2,
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
            if (itemIndex == 1) {
              return Column(
                children: [
                  Text(
                    "Method ".tr + "${itemIndex + 1}",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: AppColors.backgroundItemColor,
                        borderRadius: BorderRadius.circular(16)
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                  color: AppColors.main,
                                  shape: BoxShape.circle
                              ),
                              child: Center(
                                child: Text(
                                  "1",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textColor
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Expanded(
                                child: Text(
                                  "Open “Instagram” and tap “Copy link”".tr,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.textColor
                                  ),
                                )
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        AspectRatio(
                          aspectRatio: 348/180,
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            child: Image.asset(
                              "assets/png/help_instagram2.png",
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: AppColors.backgroundItemColor,
                        borderRadius: BorderRadius.circular(16)
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                  color: AppColors.main,
                                  shape: BoxShape.circle
                              ),
                              child: Center(
                                child: Text(
                                  "2",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textColor
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Expanded(
                                child: Text(
                                  "Open “Video Downloader”".tr,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.textColor
                                  ),
                                )
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        AspectRatio(
                          aspectRatio: 348/180,
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            child: Image.asset(
                              "assets/png/help_app_download.png",
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Obx(() => DotsIndicator(
                    dotsCount: 2,
                    position: controller.currentIndex.value.toDouble(),
                    decorator: DotsDecorator(
                        color: AppColors.gray2,
                        activeColor: AppColors.main,
                        size: Size(12, 8),
                        activeSize: Size(12, 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        spacing: EdgeInsets.only(right: 10)
                    ),
                  )),
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () => controller.onSelectDone(),
                    child: Container(
                      width: double.infinity,
                      height: 44,
                      decoration: BoxDecoration(
                          color: AppColors.main,
                          borderRadius: BorderRadius.circular(26)
                      ),
                      child: Center(
                        child: Text(
                          "Got it".tr,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              );
            }
            return Column(
              children: [
                Text(
                  "Method ".tr + "${itemIndex + 1}",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: AppColors.backgroundItemColor,
                      borderRadius: BorderRadius.circular(16)
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                                color: AppColors.main,
                                shape: BoxShape.circle
                            ),
                            child: Center(
                              child: Text(
                                "1",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textColor
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                              child: Text(
                                "Open “Instagram” and click “Share to”".tr,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textColor
                                ),
                              )
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      AspectRatio(
                        aspectRatio: 348/180,
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          child: Image.asset(
                            "assets/png/help_instagram1.png",
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: AppColors.backgroundItemColor,
                      borderRadius: BorderRadius.circular(16)
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                                color: AppColors.main,
                                shape: BoxShape.circle
                            ),
                            child: Center(
                              child: Text(
                                "2",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textColor
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                              child: Text(
                                "Click “Video Downloader”".tr,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textColor
                                ),
                              )
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      AspectRatio(
                        aspectRatio: 348/180,
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          child: Image.asset(
                            "assets/png/help_app_download.png",
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Obx(() => DotsIndicator(
                  dotsCount: 2,
                  position: controller.currentIndex.value.toDouble(),
                  decorator: DotsDecorator(
                      color: AppColors.gray2,
                      activeColor: AppColors.main,
                      size: Size(12, 8),
                      activeSize: Size(12, 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      spacing: EdgeInsets.only(right: 10)
                  ),
                )),
                const SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () => controller.onSelectNext(),
                  child: Container(
                    width: double.infinity,
                    height: 44,
                    decoration: BoxDecoration(
                        color: AppColors.main,
                        borderRadius: BorderRadius.circular(26)
                    ),
                    child: Center(
                      child: Text(
                        "Next".tr,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor
                        ),
                      ),
                    ),
                  ),
                )
              ],
            );
          }
      ),
    );
  }

  buildHelpFacebook() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: CarouselSlider.builder(
          itemCount: 2,
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
            if (itemIndex == 1) {
              return Column(
                children: [
                  Text(
                    "Method ".tr + "${itemIndex + 1}",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: AppColors.backgroundItemColor,
                        borderRadius: BorderRadius.circular(16)
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                  color: AppColors.main,
                                  shape: BoxShape.circle
                              ),
                              child: Center(
                                child: Text(
                                  "1",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textColor
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Expanded(
                                child: Text(
                                  "Open “Facebook” and tap “Copy link”".tr,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.textColor
                                  ),
                                )
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        AspectRatio(
                          aspectRatio: 348/180,
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            child: Image.asset(
                              "assets/png/help_facebook2.png",
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: AppColors.backgroundItemColor,
                        borderRadius: BorderRadius.circular(16)
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                  color: AppColors.main,
                                  shape: BoxShape.circle
                              ),
                              child: Center(
                                child: Text(
                                  "2",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textColor
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Expanded(
                                child: Text(
                                  "Open “Video Downloader”".tr,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.textColor
                                  ),
                                )
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        AspectRatio(
                          aspectRatio: 348/180,
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            child: Image.asset(
                              "assets/png/help_app_download.png",
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Obx(() => DotsIndicator(
                    dotsCount: 2,
                    position: controller.currentIndex.value.toDouble(),
                    decorator: DotsDecorator(
                        color: AppColors.gray2,
                        activeColor: AppColors.main,
                        size: Size(12, 8),
                        activeSize: Size(12, 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        spacing: EdgeInsets.only(right: 10)
                    ),
                  )),
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () => controller.onSelectDone(),
                    child: Container(
                      width: double.infinity,
                      height: 44,
                      decoration: BoxDecoration(
                          color: AppColors.main,
                          borderRadius: BorderRadius.circular(26)
                      ),
                      child: Center(
                        child: Text(
                          "Got it".tr,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              );
            }
            return Column(
              children: [
                Text(
                  "Method ".tr + "${itemIndex + 1}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundItemColor,
                    borderRadius: BorderRadius.circular(16)
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: AppColors.main,
                              shape: BoxShape.circle
                            ),
                            child: Center(
                              child: Text(
                                "1",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textColor
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: Text(
                              "Open “Facebook” and tap “Share to”".tr,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textColor
                              ),
                            )
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      AspectRatio(
                        aspectRatio: 348/180,
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          child: Image.asset(
                            "assets/png/help_facebook1.png",
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: AppColors.backgroundItemColor,
                      borderRadius: BorderRadius.circular(16)
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                                color: AppColors.main,
                                shape: BoxShape.circle
                            ),
                            child: Center(
                              child: Text(
                                "2",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textColor
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                              child: Text(
                                "Click “Video Downloader”".tr,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textColor
                                ),
                              )
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      AspectRatio(
                        aspectRatio: 348/180,
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          child: Image.asset(
                            "assets/png/help_app_download.png",
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Obx(() => DotsIndicator(
                  dotsCount: 2,
                  position: controller.currentIndex.value.toDouble(),
                  decorator: DotsDecorator(
                      color: AppColors.gray2,
                      activeColor: AppColors.main,
                      size: Size(12, 8),
                      activeSize: Size(12, 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      spacing: EdgeInsets.only(right: 10)
                  ),
                )),
                const SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () => controller.onSelectNext(),
                  child: Container(
                    width: double.infinity,
                    height: 44,
                    decoration: BoxDecoration(
                        color: AppColors.main,
                        borderRadius: BorderRadius.circular(26)
                    ),
                    child: Center(
                      child: Text(
                        "Next".tr,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor
                        ),
                      ),
                    ),
                  ),
                )
              ],
            );
          }
      ),
    );
  }

  buildNavigation() {
    return Container(
      height: 64,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  controller.onSelectBack();
                },
                child: AspectRatio(
                    aspectRatio: 1,
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 40,
                        color: Colors.transparent,
                        child: Icon(
                          Icons.arrow_back,
                          color: AppColors.textColor,
                          size: 25,
                        ),
                      ),
                    )
                ),
              ),
              Text(
                "How to use".tr,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColor
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}