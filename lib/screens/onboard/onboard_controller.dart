import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:cscmobi_app/core/base/base_controller.dart';
import 'package:cscmobi_app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/const/ad_id_extension.dart';
import '../../helper/firebase_helper.dart';
import '../../helper/firebase_remote_config_service.dart';
import '../../core/utils/app_util.dart';
import '../question/question_controller.dart';
import '../question/question_page.dart';

class OnboardStep {
  final String title;
  final String desc;
  final String image;
  final String adId;
  final String factoryId;
  final EasyAdBase? fullAd;

  OnboardStep({
    this.title = '',
    this.desc = '',
    this.image = '',
    this.adId = '',
    this.factoryId = '',
    this.fullAd,
  });
}

class OnboardController extends BaseController {
  OnboardController();

  final PageController pageController = PageController();
  var currentIndex = 0.obs;

  EasyAdBase? nativeOnboardFull1;
  EasyAdBase? nativeOnboardFull2;

  RxInt totalPage = 4.obs;
  RxBool shouldShowAdsFull1 = false.obs;
  RxBool shouldShowAdsFull2 = false.obs;
  RxBool isShowingAdsFull1 = false.obs;
  RxBool isShowingAdsFull2 = false.obs;

  RxBool isIntro1AdLoading = false.obs;
  RxBool isIntro4AdLoading = false.obs;

  StreamSubscription? _adEventSubscription;

  @override
  void onInit() {
    super.onInit();
    reloadAds();
    FirebaseHelper.setTrackingScreenName("OnboardScreen");
  }

  @override
  void onClose() {
    _adEventSubscription?.cancel();
    nativeOnboardFull1?.dispose();
    nativeOnboardFull2?.dispose();
    pageController.dispose();
    super.onClose();
  }

  onSelectBack() {
    Get.back();
  }

  reloadAds() {
    final String keyOnboard1 = FirebaseRemoteConfigService.native_onboarding_1;
    final String keyOnboardFull1 =
        FirebaseRemoteConfigService.native_onboarding_full_1;
    final String keyOnboardFull2 =
        FirebaseRemoteConfigService.native_onboarding_full_2;

    isIntro1AdLoading.value =
        FirebaseRemoteConfigService.getBoolConfigByKey(keyOnboard1);
    isIntro4AdLoading.value = false;
    update();

    Future.delayed(const Duration(seconds: 3), () {
      isIntro1AdLoading.value = false;
      update();
    });
  
    if (FirebaseRemoteConfigService.getBoolConfigByKey(keyOnboardFull1)) {
      nativeOnboardFull1 = EasyAds.instance.createNative(
        adNetwork: AdNetwork.admob,
        factoryId: 'nativeFull',
        adId: MyAdIdName.nativeOnboardFull1Ad.getId,
        height: Get.height,
      );
      final originalLoaded = nativeOnboardFull1?.onAdLoaded;
      nativeOnboardFull1?.onAdLoaded = (adNetwork, adUnitType, data) {
        originalLoaded?.call(adNetwork, adUnitType, data);
        shouldShowAdsFull1.value = true;
        isShowingAdsFull1.value = true;
        update();
      };
      nativeOnboardFull1?.load();
    }
    if (FirebaseRemoteConfigService.getBoolConfigByKey(keyOnboardFull2)) {
      nativeOnboardFull2 = EasyAds.instance.createNative(
        adNetwork: AdNetwork.admob,
        factoryId: 'nativeFull',
        adId: MyAdIdName.nativeOnboardFull2Ad.getId,
        height: Get.height,
      );
      final originalLoaded = nativeOnboardFull2?.onAdLoaded;
      nativeOnboardFull2?.onAdLoaded = (adNetwork, adUnitType, data) {
        originalLoaded?.call(adNetwork, adUnitType, data);
        shouldShowAdsFull2.value = true;
        isShowingAdsFull2.value = true;
        update();
      };
      nativeOnboardFull2?.load();
    }

    _adEventSubscription = EasyAds.instance.onEvent.listen((event) {
      if (event.type == AdEventType.adLoaded) {
        if (event.adUnitId == MyAdIdName.nativeOnboard1Ad.getId) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (!isClosed) {
              isIntro1AdLoading.value = false;
              update();
            }
          });
        } else if (event.adUnitId == MyAdIdName.nativeOnboard4Ad.getId) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (!isClosed) {
              isIntro4AdLoading.value = false;
              update();
            }
          });
        } else if (event.adUnitId == MyAdIdName.nativeOnboardFull1Ad.getId) {
          shouldShowAdsFull1.value = true;
          isShowingAdsFull1.value = true;
          update();
        } else if (event.adUnitId == MyAdIdName.nativeOnboardFull2Ad.getId) {
          shouldShowAdsFull2.value = true;
          isShowingAdsFull2.value = true;
          update();
        }
      }
    });
  }

  List<OnboardStep> getSteps() {
    final bool showAd1 = FirebaseRemoteConfigService.getBoolConfigByKey(
        FirebaseRemoteConfigService.native_onboarding_1);
    final bool showAd4 = FirebaseRemoteConfigService.getBoolConfigByKey(
        FirebaseRemoteConfigService.native_onboarding_4);

    List<OnboardStep> steps = [];

    // Onboard 1
    steps.add(OnboardStep(
      title: "Download from Any Platform".tr,
      desc:
          "Save videos from all your favorite platforms in one place. Fast, easy, and hassle-free."
              .tr,
      image: "assets/png/onboard1.png",
      adId: showAd1 ? MyAdIdName.nativeOnboard1Ad.getId : "",
      factoryId: showAd1 ? "nativeMedia" : "",
    ));
    // Full Ad 1 (inserted if loaded/showable)
    if (shouldShowAdsFull1.value && nativeOnboardFull1 != null) {
      steps.add(OnboardStep(
        fullAd: nativeOnboardFull1,
      ));
    }

    // Onboard 2
    steps.add(OnboardStep(
      title: "No Watermark, Full Quality".tr,
      desc:
          "Download videos in HD without watermarks. Keep the original quality every time."
              .tr,
      image: "assets/png/onboard2.png",
    ));

    // Onboard 3
    steps.add(OnboardStep(
      title: "More Than Just Videos".tr,
      desc:
          "Download posts, stories, MP3 audio, and turn photo slideshows into videos effortlessly."
              .tr,
      image: "assets/png/onboard3.png",
    ));
    if (shouldShowAdsFull2.value && nativeOnboardFull2 != null) {
      steps.add(OnboardStep(
        fullAd: nativeOnboardFull2,
      ));
    }

    // Onboard 4
    steps.add(OnboardStep(
      title: "Fast & Free".tr,
      desc:
          "Enjoy unlimited downloads with high speed — completely free, anytime you need."
              .tr,
      image: "assets/png/onboard4.png",
      adId: showAd4 ? MyAdIdName.nativeOnboard4Ad.getId : "",
      factoryId: showAd4 ? "nativeMedia" : "",
    ));

    // Full Ad 2 (inserted if loaded/showable)

    return steps;
  }

  int getIntroIndex(int index, List<OnboardStep> steps) {
    int introCount = 0;
    for (int i = 0; i <= index && i < steps.length; i++) {
      if (steps[i].fullAd == null) {
        introCount++;
      }
    }
    return (introCount - 1).clamp(0, 3);
  }

  onChangePage(int value) {
    currentIndex.value = value;

    final steps = getSteps();
    if (value >= 0 &&
        value < steps.length &&
        steps[value].title == "Fast & Free".tr) {
      final String keyOnboard4 =
          FirebaseRemoteConfigService.native_onboarding_4;

      final bool showAd4 =
          FirebaseRemoteConfigService.getBoolConfigByKey(keyOnboard4);
      if (showAd4) {
        isIntro4AdLoading.value = true;
        Future.delayed(const Duration(seconds: 3), () {
          isIntro4AdLoading.value = false;
          update();
        });
      }
    }

    update();
  }

  onSelectNext(List<OnboardStep> steps) {
    if (currentIndex.value < steps.length - 1) {
      currentIndex.value++;
      pageController.animateToPage(
        currentIndex.value,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Get.offWithController(
        controllerBuilder: () => QuestionController(),
        page: () => QuestionPage(),
      );
    }
    update();
  }

  String getTitleButton(int introIndex) {
    if (introIndex == 3) {
      return "Get started".tr;
    } else {
      return "Next".tr;
    }
  }
}
