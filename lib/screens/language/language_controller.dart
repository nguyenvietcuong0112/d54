import 'dart:io';

import 'package:cscmobi_app/helper/admob_ads_manager.dart';
import 'package:cscmobi_app/helper/admod_ads_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../core/base/base_controller.dart';
import '../../core/utils/app_util.dart';
import '../../helper/firebase_helper.dart';
import '../../helper/firebase_remote_config_service.dart';
import '../../models/language_model.dart';
import '../../routes/app_pages.dart';
import '../../utils/app_setting.dart';
import '../onboard/onboard_controller.dart';
import '../onboard/onboard_page.dart';
import '../tabbar/tabbar_controller.dart';
import '../tabbar/tabbar_page.dart';

class LanguageController extends BaseController {
  RxList<LanguageModel> itemsList = RxList();
  Rx<LanguageModel>? selectedLanguage;

  RxBool isFirstLaunch = false.obs;
  RxInt selectedIndex = 100.obs;
  RxBool isShowAltAds = false.obs;
  RxBool isShouldShowNext = false.obs;
  RxBool isShouldShowAds = true.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    FirebaseHelper.setTrackingScreenName("LanguageScreen");
    if (Get.arguments != null) {
      AppUtil.showLogFull("LanguageController onInit Get.arguments: ${Get.arguments}");
      isFirstLaunch.value = Get.arguments["isFirstLaunch"];
      loadAds();
      reloadAds();
    }else {
      AppUtil.showLogFull("LanguageController onInit NO ARGUMENTS");
    }
    itemsList.clear();
    itemsList.add(LanguageModel(pngAsset: 'assets/flag/flag_hindi.png', title: 'Hindi', languageCode: 'hi'));
    itemsList.add(LanguageModel(pngAsset: 'assets/flag/flag_english.png', title: 'English', languageCode: 'en'));
    itemsList.add(LanguageModel(pngAsset: 'assets/flag/flag_spain.png', title: 'Español', languageCode: 'es'));
    itemsList.add(LanguageModel(pngAsset: 'assets/flag/flag_france.png', title: 'French', languageCode: 'fr'));
    itemsList.add(LanguageModel(pngAsset: 'assets/flag/flag_philippine.png', title: 'Filipino', languageCode: 'fil'));
    itemsList.add(LanguageModel(pngAsset: 'assets/flag/flag_portuguese.png', title: 'Portuguese', languageCode: 'pt'));
    itemsList.add(LanguageModel(pngAsset: 'assets/flag/flag_bengali.png', title: 'Bengali', languageCode: 'bn'));
    itemsList.add(LanguageModel(pngAsset: 'assets/flag/flag_indonesia.png', title: 'Indonesian', languageCode: 'id'));
    itemsList.add(LanguageModel(pngAsset: 'assets/flag/flag_german.png', title: 'Deutsch', languageCode: 'de'));
    itemsList.add(LanguageModel(pngAsset: 'assets/flag/flag_thailand.png', title: 'Thai', languageCode: 'th'));
    itemsList.add(LanguageModel(pngAsset: 'assets/flag/flag_italy.png', title: 'Italian', languageCode: 'it'));
    itemsList.add(LanguageModel(pngAsset: 'assets/flag/flag_arabic.png', title: 'Arabic', languageCode: 'ar'));
    itemsList.add(LanguageModel(pngAsset: 'assets/flag/flag_turkish.png', title: 'Turkish', languageCode: 'tr'));
    itemsList.add(LanguageModel(pngAsset: 'assets/flag/flag_korea.png', title: 'Korean', languageCode: 'ko'));
    itemsList.add(LanguageModel(pngAsset: 'assets/flag/flag_japan.png', title: 'Japanese', languageCode: 'ja'));
    itemsList.add(LanguageModel(pngAsset: 'assets/flag/flag_vietnam.png', title: 'Vietnamese', languageCode: 'vi'));

    if (!isFirstLaunch.value) {
      getPreviousSelectedLanguage();
    }
  }

  reloadAds() {
    final bool isFirst = isFirstLaunch.value;
    final String keyLanguage = isFirst 
        ? FirebaseRemoteConfigService.native_language 
        : FirebaseRemoteConfigService.native_language_2f;

    if (!FirebaseRemoteConfigService.getBoolConfigByKey(keyLanguage)) {
      return;
    }
    
    // Tải Standard High Native trước
    AdmobAdsManager.reloadNativeAdsWithType(NativeAdType.nativeLanguageHighAd, false, (_nativeAd) {
      if (isClosed) {
        _nativeAd.dispose();
        return;
      }
      FirebaseHelper.logEventName(FirebaseHelper.reload_native_language_high_success, param: "");
      isNativeAdLoaded.value = false;
      nativeAd = _nativeAd;
      isNativeAdLoaded.value = true;
    });

    // Hẹn giờ 3 giây tải Standard Normal Native làm dự phòng nếu High chưa tải xong hoặc lỗi
    Future.delayed(const Duration(seconds: 3), () {
      if (nativeAd == null && isClosed == false && !isShowAltAds.value) {
        AdmobAdsManager.reloadNativeAdsWithType(NativeAdType.nativeLanguageAd, false, (_nativeAd) {
          if (isClosed) {
            _nativeAd.dispose();
            return;
          }
          FirebaseHelper.logEventName(FirebaseHelper.reload_native_language_success, param: "");
          isNativeAdLoaded.value = false;
          nativeAd = _nativeAd;
          isNativeAdLoaded.value = true;
        });
      }
    });
  }

  loadAltAds() {
    final bool isFirst = isFirstLaunch.value;
    final String keyLanguageClick = isFirst 
        ? FirebaseRemoteConfigService.native_language_click 
        : FirebaseRemoteConfigService.native_language_2f_click;

    if (!FirebaseRemoteConfigService.getBoolConfigByKey(keyLanguageClick)) {
      return;
    }

    // Tải ad Alt High trước
    AdmobAdsManager.reloadNativeAdsWithType(NativeAdType.nativeLanguageAltHighAd, false, (_nativeAd) {
      if (isClosed) {
        _nativeAd.dispose();
        return;
      }
      FirebaseHelper.logEventName(FirebaseHelper.reload_native_language_alt_high_success, param: "");
      isNativeAltAdLoaded.value = false;
      nativeAdAlt = _nativeAd;
      isNativeAltAdLoaded.value = true;
    });

    // Hẹn giờ 3 giây tải ad Alt Normal làm dự phòng
    Future.delayed(const Duration(seconds: 3), () {
      if (nativeAdAlt == null && isClosed == false) {
        AdmobAdsManager.reloadNativeAdsWithType(NativeAdType.nativeLanguageAltAd, false, (_nativeAd) {
          if (isClosed) {
            _nativeAd.dispose();
            return;
          }
          FirebaseHelper.logEventName(FirebaseHelper.reload_native_language_alt_success, param: "");
          isNativeAltAdLoaded.value = false;
          nativeAdAlt = _nativeAd;
          isNativeAltAdLoaded.value = true;
        });
      }
    });
  }

  loadAds() {
    if (isFirstLaunch.value) {
      AdmobAdsManager.loadAdmobNativeAdWithType(NativeAdType.nativeOnboard1Ad);
      AdmobAdsManager.loadAdmobNativeAdWithType(NativeAdType.nativeOnboard2Ad);
      AdmobAdsManager.loadAdmobNativeAdWithType(NativeAdType.nativeOnboardFull1Ad);
      AdmobAdsManager.loadAdmobNativeAdWithType(NativeAdType.nativeOnboardFull2Ad);
    }
  }

  onSelectItem(int index) {
    selectedIndex.value = index;
    if (!isShowAltAds.value) {
      FirebaseHelper.logEventName(FirebaseHelper.language_next_view, param: Get.currentRoute);
      // Kích hoạt tải ad Alt lúc này!
      loadAltAds();
    }
    isShowAltAds.value = true;
    Future.delayed(Duration(seconds: 2), () {
      isShouldShowNext.value = true;
    });
  }

  getPreviousSelectedLanguage() {
    String _selected = AppUtil().getUserChoosedLanguage();
    var index = -1;
    for (var i = 0; i < itemsList.length; i++) {
      if (itemsList[i].languageCode == _selected) {
        index = i;
      }
    }
    if (index >= 0) {
      selectedIndex.value = index;
    } else {
      selectedIndex.value = 0;
    }
    Locale locale = Locale(itemsList[selectedIndex.value].languageCode);
    isShouldShowNext.value = true;
  }

  onSelectBack() {
    Get.back();
  }



  onClickNext() async {
    AppUtil().saveUserChoosedLanguage(itemsList[selectedIndex.value].languageCode);
    Locale locale = Locale(itemsList[selectedIndex.value].languageCode);
    initializeDateFormatting(itemsList[selectedIndex.value].languageCode);
    AppSetting.selectedLanguageCode = itemsList[selectedIndex.value].languageCode;
    Get.updateLocale(locale);
    if (!isFirstLaunch.value) {
      Get.back();
      Get.back();
    } else {
      await Get.offWithController(controllerBuilder: () => OnboardController(), page: () => OnboardPage());
    }
  }
}
