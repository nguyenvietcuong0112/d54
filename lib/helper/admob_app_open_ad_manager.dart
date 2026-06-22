import 'dart:convert';

import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:is_lock_screen2/is_lock_screen2.dart';

import '../Utils/app_setting.dart';
import '../core/utils/app_util.dart';
import '../core/values/constants.dart';
import 'adjust_helper.dart';
import 'admob_helper.dart';

class AdmobAppOpenAdManager {
  static AppOpenAd? appOpenAd;
  static var isShowingAd = false;
  static bool isLoaded = false;
  static var isLoadingAd = false;
  static bool shouldShowOpenAds = true;

  /// Load an AppOpenAd.
  static loadAd() {
    print("run load app open");
    if (AppSetting.isPremiumUser.value) return;
    if (appOpenAd != null || isLoadingAd) {
      AppUtil.showLogFull("AdmobAppOpenAdManager loadAd: Ad is already loaded or loading, skipping.");
      return;
    }
    isLoadingAd = true;
    AppOpenAd.load(
      adUnitId: AdmobAdHelper.openAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          appOpenAd = ad;
          isLoaded = true;
          isLoadingAd = false;
          AppUtil.showLogFull("AdmobAppOpenAdManager onAdLoaded mediationAdapterClassName ${ad.responseInfo?.mediationAdapterClassName}");
          AppUtil.showLogFull("AdmobAppOpenAdManager onAdLoaded adSourceName ${ad.responseInfo?.loadedAdapterResponseInfo?.adSourceName}");
        },
        onAdFailedToLoad: (error) {
          // Handle the error.
          isLoaded = false;
          AppUtil.showLogFull("AdmobAppOpenAdManager loadAd onAdFailedToLoad error: ${error.message}");
          isLoadingAd = false;
        },
      ),
    );
  }

  static bool isShouldShowOpenAds() {
    bool isShouldShow = false;
    //Không show nếu là Premium User, hoặc Ad đagn show, hoặc Ad full đang show
    if (isShowingAd == false && appOpenAd != null && AppSetting.isPremiumUser.value == false && AppSetting.isShowingFullAd.value == false && shouldShowOpenAds) {
      isShouldShow = true;
    }

    AppUtil.showLogFull("AdmobAppOpenAdManager isShowShowOpenAds: ${isShouldShow}");
    return isShouldShow;
  }

  // Whether an ad is available to be shown.
  bool get isAdAvailable {
    return appOpenAd != null;
  }

  static Future<void> showAdIfAvailable({required Function onCloseAd}) async {
    // print("Called=====================================================================");
    if (!isShouldShowOpenAds()) {
      return;
    }
    if (appOpenAd == null) {
      AppUtil.showLogFull("AdmobAppOpenAdManager _appOpenAd NULL");
      AppUtil.showLogFull('Tried to show ad before available.');
      onCloseAd();
      loadAd();
      return;
    }
    if (isShowingAd) {
      AppUtil.showLogFull("AdmobAppOpenAdManager _appOpenAd _isShowingAd: ${isShowingAd}");
      onCloseAd();
      return;
    }
    if (AppSetting.isPremiumUser.value || !shouldShowOpenAds) {
      AppUtil.showLogFull("AdmobAppOpenAdManager _appOpenAd isPremiumUser.value: ${AppSetting.isPremiumUser.value}");
      onCloseAd();
      return;
    }
    if (AppSetting.isShowingFullAd.value) {
      AppUtil.showLogFull("AdmobAppOpenAdManager _appOpenAd isShowingFullAd.value: ${AppSetting.isShowingFullAd.value}");
      onCloseAd();
      return;
    }

    // Set the fullScreenContentCallback and show the ad.
    appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        isShowingAd = true;
        print('AdmobAppOpenAdManager $ad onAdShowedFullScreenContent');
        ad.onPaidEvent = (ad, valueMicros, precision, currencyCode) {
          AppUtil.showLog('showAdmobInterstitialAd onPaidEvent: $valueMicros - $precision - $currencyCode - ${ad.responseInfo!.adapterResponses!.length}');
          for (var response in ad.responseInfo!.adapterResponses!) {
            AppUtil.showLog(
                'showAdmobInterstitialAd Adapter response: ${response.adapterClassName} - ${response.adSourceName} - ${response.adSourceInstanceName} - ${response.description} ');
          }
          AppSetting.adImpressionCount = AppSetting.adImpressionCount++;
          AdjustHelper.adjustTrackAdRevenue(
              ad: ad,
              valueMicros: valueMicros,
              precision: precision,
              currencyCode: currencyCode,
              adOnScreen: Get.currentRoute.replaceAll('/', ''),
              adUnit: "OpenAd",
              adImpressionsCount: AppSetting.adImpressionCount);
        };
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        isShowingAd = false;
        ad.dispose();
        appOpenAd = null;
        AppUtil.showLogFull('AdmobAppOpenAdManager $ad onAdFailedToShowFullScreenContent: $error');
      },
      onAdDismissedFullScreenContent: (ad) {
        isShowingAd = false;
        ad.dispose();
        appOpenAd = null;
        onCloseAd();
        loadAd();
        AppUtil.showLogFull('AdmobAppOpenAdManager $ad onAdDismissedFullScreenContent');
      },
      onAdImpression: (ad) {
        AppUtil.showLogFull('AppOpenAd onAdImpression adImpressionCount: ${AppSetting.adImpressionCount}');
      },
    );
    appOpenAd!.show();
  }
}
