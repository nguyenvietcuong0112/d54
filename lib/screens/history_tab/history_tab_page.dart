import 'dart:typed_data';

import 'package:cscmobi_app/core/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/const/ad_id_extension.dart';
import '../../helper/firebase_remote_config_service.dart';
import 'package:cscmobi_app/ads/dimens/ad_dimen.dart';

import '../../Utils/app_setting.dart';
import '../../helper/video_download_helper.dart';
import 'history_tab_controller.dart';

class HistoryTabPage extends GetView<HistoryTabController> {
  @override
  HistoryTabController get controller => Get.isRegistered<HistoryTabController>() ? Get.find<HistoryTabController>() : Get.put(HistoryTabController());

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              buildNavigation(),
              Flexible(
                flex: 1,
                child: buildContent(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  buildContent(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          Container(
            height: 45,
            margin: const EdgeInsets.only(left: 20, right: 20),
            decoration: BoxDecoration(
              color: AppColors.backgroundItemColor,
              borderRadius: BorderRadius.circular(
                25.0,
              ),
            ),
            child: TabBar(
              controller: controller.tabController,
              // give the indicator a decoration (color and border radius)
              padding: const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  25.0,
                ),
                color: AppColors.main,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AppColors.black,
              unselectedLabelColor: AppColors.textColor,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(
                  text: 'Progress'.tr,
                ),
                Tab(
                  text: 'Downloaded'.tr,
                ),
              ],
            ),
          ),
          if (FirebaseRemoteConfigService.getBoolConfigByKey(FirebaseRemoteConfigService.native_download))
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
              child: EasyNativeAd(
                key: const ValueKey('history_download_native'),
                factoryId: 'nativeMediaSmall',
                adId: MyAdIdName.nativeDownloadAd.getId,
                height: AdDimen.smallNativeAdHeight,
              ),
            ),
          Expanded(
            child: TabBarView(
              controller: controller.tabController,
              children: <Widget>[
                buildTabProgress(),
                buildTabDownloaded(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  buildEmpty() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            "assets/png/no_data.png",
            width: 80,
            height: 180,
            fit: BoxFit.contain,
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            "No data available".tr,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondaryColor
            ),
          ),
          const SizedBox(
            height: 100,
          ),
        ],
      ),
    );
  }

  buildEmptyDownloaded() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            "assets/png/no_data.png",
            width: 80,
            height: 180,
            fit: BoxFit.contain,
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            "No data available".tr,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondaryColor
            ),
          ),
          const SizedBox(
            height: 100,
          )
        ],
      ),
    );
  }

  buildTabDownloaded() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Obx(() => controller.listDownloadItems.length > 0
          ? ListView.builder(
          itemCount: controller.listDownloadItems.length,
          padding: EdgeInsets.only(top: 5, bottom: 220),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => controller.onSelectItem(index),
              child: Container(
                width: double.infinity,
                height: 64,
                margin: EdgeInsets.only(top: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Color(0xFF2E2E39),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            height: 64,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: controller.listDownloadItems[index].type == "video" && controller.listDownloadItems[index].thumbnail.isNotEmpty
                                      ? Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                    child: Image.memory(
                                      Uint8List.fromList(controller.listDownloadItems[index].thumbnail),
                                      fit: BoxFit.cover,
                                      width: 81,
                                      height: 64,
                                    ),
                                  ) : Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                    child: Image.asset(
                                      "assets/png/video_thumb.png",
                                      fit: BoxFit.cover,
                                      width: 80,
                                      height: 64,
                                    ),
                                  )
                                ),
                                Center(
                                  child: Image.asset(
                                    'assets/png/icon_play.png',
                                    width: 24,
                                    height: 24,
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.listDownloadItems[index].name,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textColor
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  controller.listDownloadItems[index].size,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.textColor
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                        width: 40,
                        height: 40,
                        child: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          iconColor: Colors.white,
                          color: AppColors.backgroundItemColor,
                          onSelected: (value) {
                            controller.onSelectMenuItem(value, context, index);
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            PopupMenuItem<String>(
                              value: 'open',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.open_in_new,
                                    color: AppColors.white,
                                    size: 24,
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    "Open with".tr,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.white
                                    ),
                                  )
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'share',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.share_outlined,
                                    color: AppColors.white,
                                    size: 24,
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    "Share".tr,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.white
                                    ),
                                  )
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'rename',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.mode_edit_outlined,
                                    color: AppColors.white,
                                    size: 24,
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    "Rename".tr,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.white
                                    ),
                                  )
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline_outlined,
                                    color: AppColors.white,
                                    size: 24,
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    "Delete".tr,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.white
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        )
                    )
                  ],
                ),
              ),
            );
          })
          : buildEmptyDownloaded()
      )
    );
  }

  buildTabProgress() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Obx(() => VideoDownloadHelper.instance.activeDownloads.isNotEmpty
      ? ListView.builder(
        itemCount: VideoDownloadHelper.instance.activeDownloads.length,
        padding: const EdgeInsets.only(top: 5, bottom: 220),
        itemBuilder: (context, index) {
          final item = VideoDownloadHelper.instance.activeDownloads[index];
          return Obx(() => Container(
            width: double.infinity,
            height: 64,
            margin: const EdgeInsets.only(top: 15),
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  height: 64,
                  child: Stack(
                    children: [
                      Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: Image.asset(
                              "assets/png/video_thumb.png",
                              fit: BoxFit.cover,
                            ),
                          )
                      ),
                      Center(
                        child: Image.asset(
                          'assets/png/icon_play.png',
                          width: 24,
                          height: 24,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textColor
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 20,
                        width: double.infinity,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 4,
                                child: LinearProgressIndicator(
                                  value: item.progress.value,
                                  color: AppColors.main,
                                  backgroundColor: AppColors.backgroundItemColor,
                                  semanticsLabel: "",
                                  semanticsValue: "",
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            if (item.size != null && item.size!.isNotEmpty) ...[
                              Text(
                                item.size!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textColor
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                            ],
                            Text(
                              "${(item.progress.value * 100).toStringAsFixed(0)}%",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textColor
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ));
        },
      ) : buildEmpty()),
    );
  }

  buildNavigation() {
    return Container(
      height: 64,
      width: double.infinity,
      padding: const EdgeInsets.only(left: 16,),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Download".tr,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColor
              ),
            ),
          ]
      ),
    );
  }
}