import 'package:cscmobi_app/core/values/app_colors.dart';
import 'package:cscmobi_app/core/values/enums.dart';
import 'package:cscmobi_app/helper/video_download_helper.dart';
import 'package:cscmobi_app/screens/download_detail/download_detail_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Utils/app_setting.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:cscmobi_app/ads/dimens/ad_dimen.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/const/ad_id_extension.dart';
import '../../helper/firebase_remote_config_service.dart';

class DownloadDetailPage extends GetView<DownloadDetailController> {
  @override
  DownloadDetailController get controller => Get.isRegistered<DownloadDetailController>() ? Get.find<DownloadDetailController>() : Get.put(DownloadDetailController());

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              buildNavigation(),
              Expanded(
                child: buildContent(),
              ),
              FirebaseRemoteConfigService.getBoolConfigByKey(FirebaseRemoteConfigService.native_home)
                  ? EasyNativeAd(
                      key: const ValueKey('download_detail_bottom'),
                      factoryId: 'nativeMedia',
                      adId: MyAdIdName.nativeHomeAd.getId,
                      height: AdDimen.mediumNativeHeight,
                    )
                  : const SizedBox()
            ],
          ),
        ),
      ),
    );
  }

  buildContent() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          Container(
            height: 45,
            margin: EdgeInsets.only(left: 20, right: 20),
            decoration: BoxDecoration(
              color: AppColors.backgroundItemColor,
              borderRadius: BorderRadius.circular(
                25.0,
              ),
            ),
            child: TabBar(
              controller: controller.tabController,
              // give the indicator a decoration (color and border radius)
              padding: EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
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
                  text: controller.type.getName,
                  iconMargin: EdgeInsets.only(left: 0, right: 0),
                ),
                // second tab [you can add an icon using the icon property]
                Tab(
                  text: 'Progress'.tr,
                ),
                Tab(
                  text: 'Downloaded'.tr,
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: controller.tabController,
              children: <Widget>[
                buildDownloadTab(),
                buildTabProgress(),
                buildTabDownloaded()
              ],
            ),
          ),
        ],
      )
    );
  }

  buildTabDownloaded() {
    return Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Obx(() => controller.listDownloadItems.length > 0
            ? ListView.builder(
            itemCount: controller.listDownloadItems.length + 1,
            padding: EdgeInsets.only(bottom: 220, top: 5),
            itemBuilder: (context, index) {
              if (index == 0) {
                final bool showAd = FirebaseRemoteConfigService.getBoolConfigByKey(
                    FirebaseRemoteConfigService.native_home);
                if (!showAd) return const SizedBox();
                return EasyNativeAd(
                  key: const ValueKey('download_detail_inline'),
                  factoryId: 'nativeMedia',
                  adId: MyAdIdName.nativeHomeAd.getId,
                  height: AdDimen.mediumNativeHeight,
                );
              }
              return GestureDetector(
                onTap: () => controller.onSelectItem(index - 1),
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
                                      child: controller.listDownloadItems[index - 1].type == "video" && controller.listDownloadItems[index - 1].thumbnail.isNotEmpty
                                          ? Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        clipBehavior: Clip.hardEdge,
                                        child: Image.memory(
                                          Uint8List.fromList(controller.listDownloadItems[index - 1].thumbnail),
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
                                    controller.listDownloadItems[index - 1].name,
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
                                    controller.listDownloadItems[index - 1].size,
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
                              controller.onSelectMenuItem(value, context, index - 1);
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
            : buildEmpty()
        )
    );
  }

  buildTabProgress() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Obx(() => VideoDownloadHelper.instance.activeDownloads.length > 0
          ? ListView.builder(
        itemCount: VideoDownloadHelper.instance.activeDownloads.length,
        padding: EdgeInsets.only(bottom: 220, top: 20),
        itemBuilder: (context, index) {
          final item = VideoDownloadHelper.instance.activeDownloads[index];
          if ((item.type != controller.type) || item.taskId.isEmpty) {
            return Container();
          }
          return Obx(() => Container(
            width: double.infinity,
            height: 64,
            margin: EdgeInsets.only(top: 15),
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Row(
              children: [
                Container(
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
                SizedBox(
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
                                  semanticsLabel: '',
                                  semanticsValue: '',
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
                              style: TextStyle(
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

  buildDownloadTab() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: AppColors.backgroundItemColor,
              borderRadius: BorderRadius.circular(16)
            ),
            margin: EdgeInsets.only(left: 10, right: 10),
            child: Column(
              children: [
                Container(
                  height: 44,
                  width: double.infinity,
                  padding: EdgeInsets.only(left: 15, right: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: Color(0xFF353548)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextField(
                          textInputAction: TextInputAction.search,
                          focusNode: controller.focusNode,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Paste URL here'.tr,
                            icon: Image.asset(
                              "assets/png/icon_edit.png",
                              width: 20,
                              height: 20,
                            ),
                            hintStyle: TextStyle(
                                color: AppColors.textColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w400
                            ),
                          ),
                          controller: controller.urlTextFieldController,
                          onChanged: (text) => controller.onTextSearchChange(text),
                          onSubmitted: (text) => controller.onSubmitSearch(text),
                          style: TextStyle(
                              color: AppColors.textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w400
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => controller.onSelectHelp(),
                        child: Container(
                          width: 30,
                          height: 30,
                          color: Colors.transparent,
                          child: Center(
                            child: Image.asset(
                              "assets/png/icon_help.png",
                              width: 24,
                              height: 24,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () => controller.onSelectDownload(),
                  child: Container(
                    height: 46,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: AppColors.main,
                        borderRadius: BorderRadius.circular(12)
                    ),
                    child: Center(
                      child: Text(
                        "Download".tr,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          (controller.type == DownloadType.facebook || controller.type == DownloadType.instagram) ? buildStoryGuide() : Container()
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
            width: 100,
            height: 226,
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
          )
        ],
      ),
    );
  }

  buildStoryGuide() {
    return Container(
      padding: EdgeInsets.only(left: 40, right: 40),
      child: Column(
        children: [
          Image.asset(
            "assets/png/watch_story.png",
            width: 116,
            height: 80,
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            "To download private story and videos, open ".tr + controller.type.name + " in a web browser".tr,
            style: TextStyle(
                color: AppColors.textColor,
                fontSize: 14,
                fontWeight: FontWeight.w400
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () => controller.onSelectOpenBrowser(),
            child: Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(44),
                  color: AppColors.main
              ),
              child: Center(
                child: Text(
                  "Open Browser".tr,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600
                  ),
                ),
              ),
            ),
          )
        ],
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
                "HD Video Downloader & Player",
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