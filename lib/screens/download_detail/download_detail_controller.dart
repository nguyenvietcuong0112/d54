

import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:cscmobi_app/models/download_model.dart';
import 'package:cscmobi_app/models/format_model.dart';
import 'package:cscmobi_app/routes/app_pages.dart';
import 'package:cscmobi_app/screens/history_tab/history_tab_controller.dart';
import 'package:cscmobi_app/screens/home_tab/home_tab_controller.dart';
import 'package:cscmobi_app/screens/how_to_use/how_to_use_controller.dart';
import 'package:cscmobi_app/screens/how_to_use/how_to_use_page.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path/path.dart' as p;
import 'package:cscmobi_app/Utils/app_setting.dart';
import 'package:cscmobi_app/api_rest/api_repository.dart';
import 'package:cscmobi_app/core/base/base_controller.dart';
import 'package:cscmobi_app/core/values/enums.dart';
import 'package:cscmobi_app/models/realm/download_realm_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/utils/app_util.dart';
import '../../core/values/app_colors.dart';
import '../../customwidget/shimmer.dart';
import '../../helper/admob_ads_manager.dart';
import '../../helper/admod_ads_type.dart';
import '../../helper/firebase_helper.dart';
import '../../helper/firebase_remote_config_service.dart';
import '../../helper/media_store_helper.dart';
import '../../utils/Utils.dart';
import '../popup_delete/popup_delete_controller.dart';
import '../popup_delete/popup_delete_page.dart';
import '../popup_rename/popup_rename_controller.dart';
import '../popup_rename/popup_rename_page.dart';
import '../url_downloader/url_downloader_controller.dart';
import '../url_downloader/url_downloader_page.dart';

class DownloadDetailController extends BaseController with GetTickerProviderStateMixin  {
  RxBool isSearching = false.obs;
  TextEditingController urlTextFieldController = TextEditingController();
  late final TabController tabController;
  DownloadType type = DownloadType.facebook;
  RxList<DownloadRealmModel> listDownloadItems = <DownloadRealmModel>[].obs;
  var realm = AppSetting.realm;
  final FocusNode focusNode = FocusNode();
  RxList<FormatModel> videoList = <FormatModel>[].obs;
  List<FormatModel> allFormats = [];
  RxSet<int> selectedIndices = <int>{0}.obs;
  RxBool isNativeInlineAdLoaded = false.obs;
  NativeAd? nativeInlineAd;
  double currentDuration = 0.0;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    FirebaseHelper.setTrackingScreenName("DownloadDetailScreen");
    tabController = TabController(length: 3, vsync: this);
    type = Get.arguments["type"];
    getData();
    reloadAds();
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    focusNode.dispose();
    tabController.dispose();
    urlTextFieldController.dispose();
    super.onClose();
  }

  reloadAds() {
    // No native ads in download detail page according to the 20 ad units spec
  }

  getData() {
    listDownloadItems.value = [];
    var realm = AppSetting.realm;
    listDownloadItems.value = realm.all<DownloadRealmModel>().toList().reversed.toList().where((model) => model.category == type.name.toLowerCase()).toList();
    print("listDownloadItems.length: " + listDownloadItems.length.toString());
  }

  onSelectHelp() {
    Get.toWithController(
        controllerBuilder: () => HowToUseController(),
        page: () => HowToUsePage(),
        arguments: {
          "type": type,
        }
    );
  }

  onSelectOpenBrowser() {
    String defaultUrl = "";
    if (type == DownloadType.facebook) {
      defaultUrl = "https://www.facebook.com";
    } else if (type == DownloadType.instagram) {
      defaultUrl = "https://www.instagram.com";
    } else if (type == DownloadType.tiktok) {
      defaultUrl = "https://www.tiktok.com";
    } else if (type == DownloadType.twitter) {
      defaultUrl = "https://x.com";
    } else if (type == DownloadType.pinterest) {
      defaultUrl = "https://www.pinterest.com";
    }

    Get.back();
    Future.delayed(const Duration(milliseconds: 300), () {
      Get.toWithController(
          controllerBuilder: () => URLDownloaderController(),
          page: () => URLDownloaderPage(),
          arguments: {"type": type, "url": defaultUrl});
    });
  }

  onSelectDownload() async {
    try {
      FocusManager.instance.primaryFocus?.unfocus();
      if (urlTextFieldController.text.isEmpty) {
        AppUtil.showNormalToast("Please enter URL".tr);
        return;
      }
      if (Utils.isYoutubeUrl(urlTextFieldController.text)) {
        AppUtil.showNormalToast("YouTube URL is not supported".tr);
        return;
      }
      AppUtil.showLoading();
      var url = urlTextFieldController.text;
      print("run here download url: " + url);
      if (type == DownloadType.tiktok) {
        var resultUrl = await ApiRepository().sendPostRequestDownloadTiktok(url);
        if (resultUrl.code == 200 || resultUrl.code == 201) {
          videoList.value = [];
          allFormats = [];
          print("hahahaha: " + jsonEncode(resultUrl.data));
          var downloadModel = DownloadModel.fromJson(resultUrl.data);
          currentDuration = downloadModel.duration;
          
          String defaultTitle = downloadModel.title.trim();
          if (defaultTitle.isEmpty) {
            defaultTitle = "${type.getName}_Video_${DateTime.now().millisecondsSinceEpoch}";
          }
          
          for (var item in downloadModel.formats) {
            if (item.title.trim().isEmpty) {
              item.title = defaultTitle;
            }
          }
          allFormats = downloadModel.formats;
          
          Map<String, FormatModel> uniqueFormats = {};
          for (var item in downloadModel.formats) {
            String label;
            if (item.width != 0 && item.height != 0) {
              label = Utils.getVideoQualityLabel(item.width, item.height);
            } else if (item.vcodec == "none" || item.vcodec.isEmpty) {
              label = "Audio Only";
            } else {
              label = item.formatId.isNotEmpty ? "Quality: ${item.formatId}" : "Default Quality";
            }
            
            var existing = uniqueFormats[label];
            if (existing == null) {
              uniqueFormats[label] = item;
            } else {
              bool existingHasAudio = existing.acodec != "none" && existing.acodec.isNotEmpty;
              bool itemHasAudio = item.acodec != "none" && item.acodec.isNotEmpty;
              if (itemHasAudio && !existingHasAudio) {
                uniqueFormats[label] = item;
              } else if (itemHasAudio == existingHasAudio) {
                if (item.fileSize > existing.fileSize) {
                  uniqueFormats[label] = item;
                } else if (item.fileSize == existing.fileSize && item.ext == 'mp4' && existing.ext != 'mp4') {
                  uniqueFormats[label] = item;
                }
              }
            }
          }
          var sortedValues = uniqueFormats.values.toList();
          sortedValues.sort((a, b) => (b.width * b.height).compareTo(a.width * a.height));
          videoList.value = sortedValues;
          selectedIndices.assignAll({0});
          showBottomDownloadView();
        } else {
          Get.back();
          Future.delayed(const Duration(milliseconds: 300), () {
            Get.toWithController(
                controllerBuilder: () => URLDownloaderController(),
                page: () => URLDownloaderPage(),
                arguments: {"type": type, "url": url});
          });
        }
      } else {
        var resultUrl = await ApiRepository().sendPostRequestDownloadUrl(url);
        if (resultUrl.code == 200 || resultUrl.code == 201) {
          videoList.value = [];
          allFormats = [];
          var downloadModel = DownloadModel.fromJson(resultUrl.data);
          currentDuration = downloadModel.duration;
          
          String defaultTitle = downloadModel.title.trim();
          if (defaultTitle.isEmpty) {
            defaultTitle = "${type.getName}_Video_${DateTime.now().millisecondsSinceEpoch}";
          }
          
          for (var item in downloadModel.formats) {
            if (item.title.trim().isEmpty) {
              item.title = defaultTitle;
            }
          }
          allFormats = downloadModel.formats;
          
          Map<String, FormatModel> uniqueFormats = {};
          for (var item in downloadModel.formats) {
            String label;
            if (item.width != 0 && item.height != 0) {
              label = Utils.getVideoQualityLabel(item.width, item.height);
            } else if (item.vcodec == "none" || item.vcodec.isEmpty) {
              label = "Audio Only";
            } else {
              label = item.formatId.isNotEmpty ? "Quality: ${item.formatId}" : "Default Quality";
            }
            
            var existing = uniqueFormats[label];
            if (existing == null) {
              uniqueFormats[label] = item;
            } else {
              bool existingHasAudio = existing.acodec != "none" && existing.acodec.isNotEmpty;
              bool itemHasAudio = item.acodec != "none" && item.acodec.isNotEmpty;
              if (itemHasAudio && !existingHasAudio) {
                uniqueFormats[label] = item;
              } else if (itemHasAudio == existingHasAudio) {
                if (item.fileSize > existing.fileSize) {
                  uniqueFormats[label] = item;
                } else if (item.fileSize == existing.fileSize && item.ext == 'mp4' && existing.ext != 'mp4') {
                  uniqueFormats[label] = item;
                }
              }
            }
          }
          var sortedValues = uniqueFormats.values.toList();
          sortedValues.sort((a, b) => (b.width * b.height).compareTo(a.width * a.height));
          videoList.value = sortedValues;
          selectedIndices.assignAll({0});
          showBottomDownloadView();
        } else {
          Get.back();
          Future.delayed(const Duration(milliseconds: 300), () {
            Get.toWithController(
                controllerBuilder: () => URLDownloaderController(),
                page: () => URLDownloaderPage(),
                arguments: {"type": type, "url": url});
          });
        }
      }
      urlTextFieldController.text = "";
      AppUtil.hideLoading();
    } catch (e) {
      AppUtil.hideLoading();
      print("error download url: " + e.toString());
    }
  }

  FormatModel? _findBestAudioFormat(List<FormatModel> formats) {
    FormatModel? bestAudio;
    for (var f in formats) {
      if (f.vcodec == "none" && f.acodec != "none") {
        if (bestAudio == null || f.fileSize > bestAudio.fileSize) {
          bestAudio = f;
        }
      }
    }
    return bestAudio;
  }

  onSelectDownloadURL(List<FormatModel> selectedFormats) {
    Get.back();
    if (selectedFormats.isEmpty) return;

    if (Get.isRegistered<HistoryTabController>()) {
      var controller = Get.isRegistered<HistoryTabController>() ? Get.find<HistoryTabController>() : Get.put(HistoryTabController());
      Map<String, String> headers = {
        "User-Agent": "Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Mobile Safari/537.36",
      };
      if (type == DownloadType.facebook) {
        headers["Referer"] = "https://www.facebook.com/";
      } else if (type == DownloadType.instagram) {
        headers["Referer"] = "https://www.instagram.com/";
      } else if (type == DownloadType.tiktok) {
        headers["Referer"] = "https://www.tiktok.com/";
      } else if (type == DownloadType.twitter) {
        headers["Referer"] = "https://x.com/";
      }
      for (var format in selectedFormats) {
        var newName = format.title.trim();
        if (newName.isEmpty) {
          newName = "${type.getName}_Video_${DateTime.now().millisecondsSinceEpoch}";
        }
        if (newName.length > 100) {
          newName = newName.substring(0, 100);
        }
        
        String? audioUrl;
        bool isVideoOnly = format.acodec == "none" || format.acodec.isEmpty;
        if (isVideoOnly) {
          var bestAudio = _findBestAudioFormat(allFormats);
          if (bestAudio != null) {
            audioUrl = bestAudio.url;
          }
        }
        
        controller.onStartDownload(
          format.url,
          newName,
          type,
          audioUrl: audioUrl,
          duration: currentDuration,
          size: format.fileSize > 0 ? MediaStoreHelper.convertFileSizeToString(format.fileSize.toInt()) : null,
          headers: headers,
        );
      }
    }
    Future.delayed(Duration(seconds: 1), () {
      tabController.animateTo(1, duration: Duration(milliseconds: 200));
    });
  }

  onSelectItem(index) async {
    AdmobAdsManager.showAdmobInterstitialAdWithType(InterAdType.interPlayAd, onNextScreen: () async {
      var existFile = await MediaStoreHelper.fileExists(listDownloadItems[index].url);
      if (!existFile) {
        AppUtil.showNormalToast("File not found".tr);
        return;
      }
      openMyFile(listDownloadItems[index].url);
    });
  }

  onSelectMenuItem(value, context, index) async {
    if (value == 'open') {
      AdmobAdsManager.showAdmobInterstitialAdWithType(InterAdType.interPlayAd, onNextScreen: () async {
        var existFile = await MediaStoreHelper.fileExists(listDownloadItems[index].url);
        if (!existFile) {
          AppUtil.showNormalToast("File not found".tr);
          return;
        }
        openMyFile(listDownloadItems[index].url);
      });
    } else if (value == 'play') {
      // Logic for play if any
    } else if (value == 'share') {
      var existFile = await MediaStoreHelper.fileExists(listDownloadItems[index].url);
      if (!existFile) {
        AppUtil.showNormalToast("File not found".tr);
        return;
      }
      var file = await MediaStoreHelper.readFile(listDownloadItems[index].url);
      Share.shareXFiles([XFile(file.path)]);
    } else if (value == 'rename') {
      var existFile = await MediaStoreHelper.fileExists(listDownloadItems[index].url);
      if (!existFile) {
        AppUtil.showNormalToast("File not found".tr);
        return;
      }
      var file = await MediaStoreHelper.readFile(listDownloadItems[index].url);
      var result = await Get.dialog(GetBuilder<PopupRenameController>(
        init: PopupRenameController(), // Optional: Initialize controller here if needed
        builder: (controller) {
          return PopupRenamePage();
        },
      ),
          useSafeArea: true,
          arguments: {
            "outputFile": file,
            "name": getBaseName(listDownloadItems[index].name),
          }
      );
      if (result != null) {
        var newName = result["newName"];
        if (listDownloadItems[index].type == "audio") {
          await renameAudioKeepExt(file, listDownloadItems[index].url, newName);
        } else {
          await renameVideoKeepExt(listDownloadItems[index].url, newName);
        }
        realm.write(() {
          listDownloadItems[index].name = newName + Utils.getVideoExtension2(listDownloadItems[index].name);
        });
        getData();
      }
    } else if (value == 'delete') {
      deleteFile(index);
    }
  }

  Future<void> openMyFile(String path) async {
    final uri = Uri.parse(path);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw "Could not open $path";
    }
  }

  deleteFile(index) async {
    var result = await Get.dialog(GetBuilder<PopupDeleteController>(
      init: PopupDeleteController(), // Optional: Initialize controller here if needed
      builder: (controller) {
        return PopupDeletePage();
      },
    ),
        useSafeArea: true,
        arguments: {
          "titleButton1": "Cancel".tr,
          "titleButton2": "Delete".tr,
          "title": "Delete video".tr,
          "desc": "Do you want to delete now?".tr,
        }
    );
    if (result == null || result["result"] != true) {
      return;
    }
    var media = listDownloadItems[index];
    try {
      var existFile = await MediaStoreHelper.fileExists(listDownloadItems[index].url);
      if (existFile) {
        await MediaStoreHelper.deleteFileByUri(media.url);
      } else {
      }
      realm.write(() {
        realm.delete(media);
      });
      getData();
      AppUtil.showNormalToast("Delete success".tr);
    } catch (e) {
      print("error delete file: " + e.toString());
    }
  }

  String getBaseName(String fileName) {
    return p.basenameWithoutExtension(fileName);
  }

  Future<File> renameAudioKeepExt(File file, String deviceUri, String newBaseName) async {
    await MediaStoreHelper.renameAudio(uri: deviceUri, displayName: newBaseName);
    var newFile = await MediaStoreHelper.readFile(deviceUri);
    return newFile;
  }

  Future<File> renameVideoKeepExt(String deviceUri, String newBaseName) async {
    await MediaStoreHelper.renameMedia(deviceUri, newBaseName);
    var newFile = await MediaStoreHelper.readFile(deviceUri);
    return newFile;
  }


  onStartSearch() {
    isSearching.value = true;
  }

  onEndSearch() {
    isSearching.value = false;
    urlTextFieldController.text = "";
    FocusManager.instance.primaryFocus?.unfocus();
    update();
  }

  onSubmitSearch(String text) {
    FocusManager.instance.primaryFocus?.unfocus();
  }


  onTextSearchChange(String text) {
    update();
  }

  onSelectBack() {
    Get.back();
  }

  onSelectEditName(int index) async {
    Get.back();
    var result = await Get.dialog(GetBuilder<PopupRenameController>(
      init: PopupRenameController(), // Optional: Initialize controller here if needed
      builder: (controller) {
        return PopupRenamePage();
      },
    ),
        useSafeArea: true,
        arguments: {
          "name": videoList[index].title,
        }
    );
    videoList[index].title = result != null && result['newName'] != null ? result['newName'] : videoList[index].title;
    showBottomDownloadView();
  }

  onSelectClosePopup() {
    Get.back();
  }

  String _getFormatDisplaySubtitle(FormatModel video) {
    String label = "";
    if (video.width == 0 || video.height == 0) {
      label = (video.vcodec == "none" || video.vcodec.isEmpty) ? "Audio Only".tr : "Default Quality".tr;
    } else {
      label = Utils.getVideoQualityLabel(video.width, video.height);
      bool isVideoOnly = video.acodec == "none" || video.acodec.isEmpty;
      if (isVideoOnly) {
        label += " | " + "Video Only (Merge Audio)".tr;
      } else {
        label += " | " + "Video + Audio".tr;
      }
    }
    if (video.fileSize > 0) {
      label += " (${MediaStoreHelper.convertFileSizeToString(video.fileSize.toInt())})";
    }
    return label;
  }

  showBottomDownloadView() {
    Get.bottomSheet(
        Container(
          child: Container(
            width: double.infinity,
            height: 600,
            decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16)
                )
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Obx(() {
                    return ListView.builder(
                      itemCount: videoList.length,
                      padding: EdgeInsets.only(bottom: 100),
                      itemBuilder: (context, index) {
                        final video = videoList[index];
                        return GestureDetector(
                          onTap: () {
                            if (selectedIndices.contains(index)) {
                              selectedIndices.remove(index);
                            } else {
                              selectedIndices.add(index);
                            }
                          },
                          child: Container(
                            height: 100,
                            width: double.infinity,
                            padding: EdgeInsets.only(left: 10, right: 10),
                            decoration: BoxDecoration(
                                color: Colors.transparent
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Obx(() => selectedIndices.contains(index)
                                    ? Container(
                                  width: 30,
                                  height: 30,
                                  child: Center(
                                    child: Icon(
                                      Icons.check_box_rounded,
                                      size: 24,
                                      color: AppColors.main,
                                    ),
                                  ),
                                )
                                    : Container(
                                  width: 30,
                                  height: 30,
                                  child: Center(
                                    child: Icon(
                                      Icons.check_box_outline_blank_outlined,
                                      size: 24,
                                      color: AppColors.gray,
                                    ),
                                  ),
                                )),
                                const SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  width: 120,
                                  height: 80,
                                  child: CachedNetworkImage(
                                    imageUrl: video.thumbnailUrl,
                                    fit: BoxFit.cover,
                                    maxWidthDiskCache: 120,
                                    maxHeightDiskCache: 80,
                                    memCacheWidth: 120,
                                    memCacheHeight: 80,
                                    placeholder: (context, url) => Shimmer.fromColors(
                                      baseColor: Colors.grey.shade300,
                                      highlightColor: Colors.grey.shade100,
                                      child: Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => const Center(
                                      child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.only(top: 10, bottom: 10),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          video.title,
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.textColor
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                         Text(
                                           _getFormatDisplaySubtitle(video),
                                           style: TextStyle(
                                               fontSize: 12,
                                               fontWeight: FontWeight.w500,
                                               color: AppColors.lightGreyColor
                                           ),
                                         )
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                GestureDetector(
                                  onTap: () => onSelectEditName(index),
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    child: Center(
                                      child: Image.asset(
                                        "assets/png/icon_edit_white.png",
                                        width: 24,
                                        height: 24,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 90,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Color(0xFF161625)
                    ),
                    child: Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () => onSelectClosePopup(),
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colors.transparent
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/png/icon_close2.png",
                                    width: 40,
                                    height: 40,
                                  ),
                                  Text(
                                    "Close".tr,
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.textColor
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              List<FormatModel> selected = [];
                              for (var idx in selectedIndices) {
                                if (idx < videoList.length) {
                                  selected.add(videoList[idx]);
                                }
                              }
                              onSelectDownloadURL(selected);
                            },
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colors.transparent
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/png/icon_download2.png",
                                    width: 40,
                                    height: 40,
                                  ),
                                  Text(
                                    "Download".tr,
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.textColor
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        )
    );
  }
}