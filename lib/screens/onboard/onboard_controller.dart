import 'package:carousel_slider/carousel_controller.dart';
import 'package:cscmobi_app/core/base/base_controller.dart';
import 'package:cscmobi_app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../helper/admob_ads_manager.dart';
import '../../helper/admod_ads_type.dart';
import '../../helper/firebase_helper.dart';
import '../../helper/firebase_remote_config_service.dart';
import '../../core/utils/app_util.dart';
import '../question/question_controller.dart';
import '../question/question_page.dart';

class OnboardController extends BaseController {
  OnboardController();
  CarouselSliderController activityController = CarouselSliderController();
  var currentIndex = 0.obs;
  NativeAd? nativeOnboardFull1;
  NativeAd? nativeOnboardFull2;
  RxInt totalPage = 4.obs; // Đổi từ 3 sang 4 màn hình Intro
  RxBool shouldShowAdsFull1 = false.obs;
  RxBool shouldShowAdsFull2 = false.obs;
  RxBool isShowingAdsFull1 = false.obs;
  RxBool isShowingAdsFull2 = false.obs;
  RxInt currentTabOnboard = 0.obs;

  @override
  void onInit() {
    super.onInit();
    reloadAds();
    loadAds();
    FirebaseHelper.setTrackingScreenName("OnboardScreen");
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  onSelectBack() {
    Get.back();
  }

  RxBool isIntro1AdLoading = false.obs;
  RxBool isIntro4AdLoading = false.obs;

  reloadAds() {
    final bool isSecond = AppUtil.getBool("isNoFirstOpenApp");
    final String keyOnboard1 = isSecond 
        ? FirebaseRemoteConfigService.native_onboarding_1_2 
        : FirebaseRemoteConfigService.native_onboarding_1_1;
    final String keyOnboard4 = isSecond 
        ? FirebaseRemoteConfigService.native_onboarding_4_2 
        : FirebaseRemoteConfigService.native_onboarding_4_1;
    final String keyOnboardFull1 = FirebaseRemoteConfigService.native_onboarding_full_1;
    final String keyOnboardFull2 = FirebaseRemoteConfigService.native_onboarding_full_2;

    isIntro1AdLoading.value = FirebaseRemoteConfigService.getBoolConfigByKey(keyOnboard1);
    isIntro4AdLoading.value = FirebaseRemoteConfigService.getBoolConfigByKey(keyOnboard4);

    // Bộ đệm tối đa 3 giây đề phòng ad loading lỗi hoặc No fill
    Future.delayed(const Duration(seconds: 3), () {
      isIntro1AdLoading.value = false;
      isIntro4AdLoading.value = false;
      update();
    });

    if (FirebaseRemoteConfigService.getBoolConfigByKey(keyOnboard1)) {
      AdmobAdsManager.reloadNativeAdsWithType(NativeAdType.nativeOnboard1Ad, false, (_nativeAd) {
        if (isClosed) {
          _nativeAd.dispose();
          return;
        }
        isNativeAdLoaded.value = false;
        nativeAd  = _nativeAd;
        isNativeAdLoaded.value = true;
        isIntro1AdLoading.value = false;
        update();
      });
    }
    if (FirebaseRemoteConfigService.getBoolConfigByKey(keyOnboard4)) {
      AdmobAdsManager.reloadNativeAdsWithType(NativeAdType.nativeOnboard2Ad, false, (_nativeAd) {
        if (isClosed) {
          _nativeAd.dispose();
          return;
        }
        isNativeAltAdLoaded.value = false;
        nativeAdAlt  = _nativeAd;
        isNativeAltAdLoaded.value = true;
        isIntro4AdLoading.value = false;
        update();
      });
    }
    if (FirebaseRemoteConfigService.getBoolConfigByKey(keyOnboardFull1)) {
      AdmobAdsManager.reloadNativeAdsWithType(NativeAdType.nativeOnboardFull1Ad, false, (_nativeAd) {
        if (isClosed) {
          _nativeAd.dispose();
          return;
        }
        print("reload nativeOnboardFull1Ad");
        nativeOnboardFull1 = _nativeAd;
        shouldShowAdsFull1.value = true;
      });
    }
    if (FirebaseRemoteConfigService.getBoolConfigByKey(keyOnboardFull2)) {
      AdmobAdsManager.reloadNativeAdsWithType(NativeAdType.nativeOnboardFull2Ad, false, (_nativeAd) {
        if (isClosed) {
          _nativeAd.dispose();
          return;
        }
        print("reload nativeOnboardFull2Ad");
        nativeOnboardFull2 = _nativeAd;
        shouldShowAdsFull2.value = true;
      });
    }
  }

  loadAds() {
    // Lazy Load
  }

  onChangePage(int value) {
    if (value == 1) {
      if (!shouldShowAdsFull1.value) {
        if (currentIndex.value > 1) {
          activityController.jumpToPage(0);
          currentIndex.value = 0;
        } else {
          activityController.jumpToPage(2);
          currentIndex.value = 2;
        }
      } else {
        currentIndex.value = value;
      }
    } else if (value == 4) {
      if (!shouldShowAdsFull2.value) {
        if (currentIndex.value > 4) {
          activityController.jumpToPage(3);
          currentIndex.value = 3;
        } else {
          activityController.jumpToPage(5);
          currentIndex.value = 5;
        }
      } else {
        currentIndex.value = value;
      }
    } else {
      currentIndex.value = value;
    }
    
    // Ánh xạ tab hướng dẫn (DotsIndicator có 4 tab: 0, 1, 2, 3)
    if (currentIndex.value == 0 || currentIndex.value == 1) {
      currentTabOnboard.value = 0;
    } else if (currentIndex.value == 2) {
      currentTabOnboard.value = 1;
    } else if (currentIndex.value == 3 || currentIndex.value == 4) {
      currentTabOnboard.value = 2;
    } else {
      currentTabOnboard.value = 3;
    }
    update();
  }

  onSelectNext() {
    if (currentIndex.value == 5) {
      Get.offWithController(controllerBuilder: () => QuestionController(), page: () => QuestionPage());
      return;
    }
    if (currentIndex.value == 0) {
      if (shouldShowAdsFull1.value) {
        activityController.jumpToPage(1);
      } else {
        activityController.jumpToPage(2);
      }
    } else if (currentIndex.value == 1) {
      activityController.jumpToPage(2);
    } else if (currentIndex.value == 2) {
      activityController.jumpToPage(3);
    } else if (currentIndex.value == 3) {
      if (shouldShowAdsFull2.value) {
        activityController.jumpToPage(4);
      } else {
        activityController.jumpToPage(5);
      }
    } else if (currentIndex.value == 4) {
      activityController.jumpToPage(5);
    }
    update();
  }

  String getTitle() {
    if (currentTabOnboard.value == 0) {
      return "Download from Any Platform".tr;
    } else if (currentTabOnboard.value == 1) {
      return "No Watermark, Full Quality".tr;
    } else if (currentTabOnboard.value == 2) {
      return "More Than Just Videos".tr;
    } else {
      return "Fast & Free".tr;
    }
  }

  String getDesc() {
    if (currentTabOnboard.value == 0) {
      return "Save videos from all your favorite platforms in one place. Fast, easy, and hassle-free.".tr;
    } else if (currentTabOnboard.value == 1) {
      return "Download videos in HD without watermarks. Keep the original quality every time.".tr;
    } else if (currentTabOnboard.value == 2) {
      return "Download posts, stories, MP3 audio, and turn photo slideshows into videos effortlessly.".tr;
    } else {
      return "Enjoy unlimited downloads with high speed — completely free, anytime you need.".tr;
    }
  }

  String getThumb() {
    if (currentTabOnboard.value == 0) {
      return "assets/png/onboard1.png";
    } else if (currentTabOnboard.value == 1) {
      return "assets/png/onboard2.png";
    } else if (currentTabOnboard.value == 2) {
      return "assets/png/onboard3.png";
    } else {
      return "assets/png/onboard4.png";
    }
  }

  String getTitleButton(int index) {
    if (index == 0 || index == 1 || index == 2) {
      return "Next".tr;
    } else {
      return "Get started".tr;
    }
  }
}