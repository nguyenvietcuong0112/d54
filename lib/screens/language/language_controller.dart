import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/const/ad_id_extension.dart';
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

class LanguageController extends BaseController {
  RxList<LanguageModel> itemsList = RxList();
  Rx<LanguageModel>? selectedLanguage;

  RxBool isFirstLaunch = false.obs;
  RxInt selectedIndex = 100.obs;
  RxBool isShowAltAds = false.obs;
  RxBool isShouldShowNext = false.obs;
  RxBool isShouldShowAds = true.obs;
  RxBool isLoading = true.obs;
  RxBool isButtonLoading = false.obs;

  RxBool showLanguageAd = false.obs;
  RxBool showLanguageClickAd = false.obs;

  StreamSubscription? _adEventSubscription;
  Timer? _timeoutTimer;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    Timer(const Duration(milliseconds: 2500), () {
      isLoading.value = false;
    });

    showLanguageAd.value = FirebaseRemoteConfigService.getBoolConfigByKey(
        FirebaseRemoteConfigService.native_language);
    showLanguageClickAd.value = FirebaseRemoteConfigService.getBoolConfigByKey(
        FirebaseRemoteConfigService.native_language_click);

    FirebaseHelper.setTrackingScreenName("LanguageScreen");
    if (Get.arguments != null) {
      AppUtil.showLogFull("LanguageController onInit Get.arguments: ${Get.arguments}");
      isFirstLaunch.value = Get.arguments["isFirstLaunch"];
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

  onSelectItem(int index) {
    if (selectedIndex.value == 100) {
      isButtonLoading.value = true;
      Timer(const Duration(seconds: 2), () {
        isButtonLoading.value = false;
      });
    }
    selectedIndex.value = index;
    if (!isShowAltAds.value) {
      FirebaseHelper.logEventName(FirebaseHelper.language_next_view, param: Get.currentRoute);
    }

    if (showLanguageClickAd.value) {
      isShowAltAds.value = true;
      isShouldShowNext.value = false;

      _timeoutTimer?.cancel();
      _timeoutTimer = Timer(const Duration(seconds: 3), () {
        if (!isShouldShowNext.value && !isClosed) {
          isShouldShowNext.value = true;
        }
      });

      final ad = EasyAds.instance.getCachedNativeAd(MyAdIdName.nativeLanguageClick);
      if (ad != null && ad.isAdLoaded) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (!isShouldShowNext.value && !isClosed) {
            isShouldShowNext.value = true;
          }
        });
      } else {
        _adEventSubscription?.cancel();
        _adEventSubscription = EasyAds.instance.onEvent.listen((event) {
          if (event.adUnitId == MyAdIdName.nativeLanguageClick.getId &&
              event.type == AdEventType.adLoaded) {
            _adEventSubscription?.cancel();
            Future.delayed(const Duration(milliseconds: 800), () {
              if (!isShouldShowNext.value && !isClosed) {
                isShouldShowNext.value = true;
              }
            });
          }
        });
      }
    } else {
      isShouldShowNext.value = true;
    }
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
      await Get.offWithController(controllerBuilder: () => OnboardController(), page: () => const OnboardPage());
    }
  }

  @override
  void onClose() {
    _adEventSubscription?.cancel();
    _timeoutTimer?.cancel();
    super.onClose();
  }
}
