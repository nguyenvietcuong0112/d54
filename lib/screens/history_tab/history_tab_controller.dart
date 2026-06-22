import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cscmobi_app/Utils/app_setting.dart';
import 'package:cscmobi_app/core/base/base_controller.dart';
import 'package:cscmobi_app/core/values/enums.dart';
import 'package:cscmobi_app/helper/firebase_helper.dart';
import 'package:cscmobi_app/helper/video_download_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import '../../core/utils/app_util.dart';
import '../../helper/admob_ads_manager.dart';
import '../../helper/admod_ads_type.dart';
import '../../helper/firebase_remote_config_service.dart';
import '../../helper/media_store_helper.dart';
import '../../models/realm/download_realm_model.dart';
import '../../utils/Utils.dart';
import '../popup_delete/popup_delete_controller.dart';
import '../popup_delete/popup_delete_page.dart';
import '../popup_rename/popup_rename_controller.dart';
import '../popup_rename/popup_rename_page.dart';

class HistoryTabController extends BaseController with GetTickerProviderStateMixin  {
  late final TabController tabController;
  RxList<DownloadRealmModel> listDownloadItems = <DownloadRealmModel>[].obs;
  var realm = AppSetting.realm;

  RxBool isNativeInlineAdLoaded = false.obs;
  NativeAd? nativeInlineAd;

  // native_download: native nhỏ xen kẽ trong list data (cách 3 data đặt 1 ads)
  RxMap<int, NativeAd?> nativeDownloadAds = <int, NativeAd?>{}.obs;
  RxMap<int, bool> isNativeDownloadAdLoaded = <int, bool>{}.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    // Load inter_play ad cho video play
    if (FirebaseRemoteConfigService.getBoolConfigByKey(FirebaseRemoteConfigService.inter_play)) {
      AdmobAdsManager.loadAdmobInterstitialAdWithType(InterAdType.interPlayAd);
    }
    tabController = TabController(length: 2, vsync: this);
    getData();
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    reloadAds();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    // Dispose các native download ads
    nativeDownloadAds.forEach((key, ad) {
      ad?.dispose();
    });
    nativeDownloadAds.clear();
  }

  reloadAds() {
    if (FirebaseRemoteConfigService.getBoolConfigByKey(FirebaseRemoteConfigService.native_home)) {
      AdmobAdsManager.reloadNativeAdsWithType(NativeAdType.nativeHomeMediumAd, true, (_nativeAd) {
        if (isClosed) {
          _nativeAd.dispose();
          return;
        }
        isNativeAdLoaded.value = false;
        nativeAd = _nativeAd;
        isNativeAdLoaded.value = true;
      });
      if (listDownloadItems.isNotEmpty) {
        AdmobAdsManager.reloadNativeAdsWithType(NativeAdType.nativeHome2Ad, true, (_nativeAd) {
          if (isClosed) {
            _nativeAd.dispose();
            return;
          }
          isNativeInlineAdLoaded.value = false;
          nativeInlineAd = _nativeAd;
          isNativeInlineAdLoaded.value = true;
        });
      }
    }
    // Load native_download ads
    _loadNativeDownloadAds();
  }

  // Tải native download ads cho các vị trí xen kẽ (cách 3 data đặt 1 ads)
  _loadNativeDownloadAds() {
    if (!FirebaseRemoteConfigService.getBoolConfigByKey(FirebaseRemoteConfigService.native_download)) return;
    if (listDownloadItems.isEmpty) return;

    // Tính số lượng ads cần load: cách 3 item đặt 1 ads
    // Vị trí ad: sau item 2 (index 3), sau item 5 (index 6), sau item 8 (index 9)...
    int adCount = (listDownloadItems.length / 3).floor();
    for (int i = 0; i < adCount; i++) {
      int adSlotIndex = i; // Dùng làm key cho map
      if (nativeDownloadAds[adSlotIndex] == null && isNativeDownloadAdLoaded[adSlotIndex] != true) {
        AdmobAdsManager.reloadNativeAdsWithType(NativeAdType.nativeDownloadAd, false, (_nativeAd) {
          if (isClosed) {
            _nativeAd.dispose();
            return;
          }
          nativeDownloadAds[adSlotIndex] = _nativeAd;
          isNativeDownloadAdLoaded[adSlotIndex] = true;
        });
      }
    }
  }

  // Tính tổng items (data + ads) cho ListView
  int get totalListItems {
    if (listDownloadItems.isEmpty) return 0;
    int dataCount = listDownloadItems.length;
    int adCount = (dataCount / 3).floor();
    return dataCount + adCount;
  }

  // Kiểm tra vị trí index có phải ad slot không
  // Pattern: 3 data items rồi 1 ad: [d0, d1, d2, AD, d3, d4, d5, AD, ...]
  bool isAdPosition(int index) {
    if (index == 0) return false;
    // Vị trí ad: index 3, 7, 11, 15... (sau mỗi 3 data items + các ad trước đó)
    // Formula: (index + 1) % 4 == 0
    return (index + 1) % 4 == 0;
  }

  // Lấy index data thực từ list index (trừ đi các ad slots)
  int getDataIndex(int listIndex) {
    // Số ad slots trước listIndex
    int adsBefore = (listIndex) ~/ 4; // Mỗi nhóm 4 (3 data + 1 ad) có 1 ad
    return listIndex - adsBefore;
  }

  // Lấy ad slot index từ list index
  int getAdSlotIndex(int listIndex) {
    return (listIndex + 1) ~/ 4 - 1;
  }

  getData() {
    var realm = AppSetting.realm;
    listDownloadItems.value = realm.all<DownloadRealmModel>().toList();
  }

  // inter_play: hiển thị khi user click play video trong list Download
  onSelectItem(index) async {
    // Kiểm tra xem item có phải video không
    if (index < listDownloadItems.length && listDownloadItems[index].type == "video") {
      // Hiển thị inter_play trước khi mở video
      AdmobAdsManager.showAdmobInterstitialAdWithType(InterAdType.interPlayAd, onNextScreen: () async {
        var existFile = await MediaStoreHelper.fileExists(listDownloadItems[index].url);
        if (!existFile) {
          AppUtil.showNormalToast("File not found".tr);
          return;
        }
        openMyFile(listDownloadItems[index].url);
      });
    } else {
      // Non-video items: mở trực tiếp không qua inter
      var existFile = await MediaStoreHelper.fileExists(listDownloadItems[index].url);
      if (!existFile) {
        AppUtil.showNormalToast("File not found".tr);
        return;
      }
      openMyFile(listDownloadItems[index].url);
    }
  }

  onSelectMenuItem(value, context, index) async {
    if (value == 'open') {
      // open with: cũng kiểm tra inter_play nếu là video
      if (index < listDownloadItems.length && listDownloadItems[index].type == "video") {
        AdmobAdsManager.showAdmobInterstitialAdWithType(InterAdType.interPlayAd, onNextScreen: () async {
          var existFile = await MediaStoreHelper.fileExists(listDownloadItems[index].url);
          if (!existFile) {
            AppUtil.showNormalToast("File not found".tr);
            return;
          }
          openMyFile(listDownloadItems[index].url);
        });
      } else {
        var existFile = await MediaStoreHelper.fileExists(listDownloadItems[index].url);
        if (!existFile) {
          AppUtil.showNormalToast("File not found".tr);
          return;
        }
        openMyFile(listDownloadItems[index].url);
      }
    } else if (value == 'play') {
      // play: hiển thị inter_play
      if (index < listDownloadItems.length) {
        AdmobAdsManager.showAdmobInterstitialAdWithType(InterAdType.interPlayAd, onNextScreen: () async {
          var existFile = await MediaStoreHelper.fileExists(listDownloadItems[index].url);
          if (!existFile) {
            AppUtil.showNormalToast("File not found".tr);
            return;
          }
          openMyFile(listDownloadItems[index].url);
        });
      }
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

  onStartDownload(String url, String name, DownloadType type, {String? audioUrl, double? duration, String? size, Map<String, String>? headers}) async {
    FirebaseHelper.logEventName("Download_" + type.name, param: "");
    var result = await VideoDownloadHelper.instance.download(
      videoUrl: url,
      title: name,
      type: type,
      audioUrl: audioUrl,
      duration: duration,
      size: size,
      headers: headers,
    );
  }
}