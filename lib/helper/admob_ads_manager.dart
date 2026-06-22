import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../core/utils/app_util.dart';
import '../core/values/app_colors.dart';
import '../core/values/constants.dart';
import 'adjust_helper.dart';
import 'admob_helper.dart';
import 'admod_ads_type.dart';
import 'firebase_helper.dart';
import '../Utils/app_setting.dart';
import 'firebase_remote_config_service.dart';

class AdmobAdsManager {
  //Native ads
  static Map<NativeAdType, NativeAd?> nativeAds = {};
  //Full ads
  static Map<InterAdType, InterstitialAd?> interAds = {};
  static AppOpenAd? appOpenAd;
  //Banner ads
  static Map<BannerAdType, BannerAd?> bannerAds = {};

  //Flag loading ads
  static Map<NativeAdType, bool> isLoadingNative = {};
  static Map<BannerAdType, bool> isLoadingBanner = {};
  static Map<InterAdType, bool> isLoadingInter = {};

  //Flag loading ads full
  static bool isLoadingAppOpenAd = false;

  //Retry load ads
  static int maxFailedLoadAttempts = 1;
  static int maxFailedBannerNativeLoadAttempts = 1;

  // Track failed attempts for each ad type to avoid recursive loops
  static final Map<NativeAdType, int> _failedNativeLoadAttempts = {};
  static final Map<BannerAdType, int> _failedBannerLoadAttempts = {};

  //Time to reload ads
  static DateTime lastTimeShowAdsFull = DateTime.now();
  static DateTime lastTimeReloadNativeAdsHome = DateTime.now();
  static DateTime timeStartLoadInterOpen = DateTime.now();

  static final Map<NativeAdType, List<Function(NativeAd)>> _callbackNativeAds =
      {};
  static final Map<BannerAdType, List<Function(BannerAd)>> _callbackBannerAds =
      {};

  static bool checkCanShowAdsFull() {
    AppSetting.interval_inter_ad =
        FirebaseRemoteConfigService.getIntConfigByKey(
            FirebaseRemoteConfigService.interval_inter_ad);
    var diff = DateTime.now().difference(AdmobAdsManager.lastTimeShowAdsFull);
    if (diff.inSeconds > AppSetting.interval_inter_ad) {
      return true;
    } else {
      return false;
    }
  }

  //region Admob ads
  static loadAdmobBannerAd(BannerAdType bannerAdType) async {
    try {
      // 1. Kiểm tra quyền lợi người dùng
      if (AppSetting.isPremiumUser.value || AppSetting.isRemoveAds.value)
        return;

      // 2. Khởi tạo giá trị mặc định nếu chưa có
      isLoadingBanner[bannerAdType] ??= false;
      bannerAds[bannerAdType] ??= null;

      // 3. QUAN TRỌNG: Kiểm tra trạng thái loading TRƯỚC khi log event
      if (isLoadingBanner[bannerAdType] == true) {
        AppUtil.showLog(
            "AdmobAdsManager: ${bannerAdType.name} đang load, bỏ qua yêu cầu trùng.");
        return;
      }

      // 4. KHÓA trạng thái loading ngay lập tức
      isLoadingBanner[bannerAdType] = true;

      // 5. LOG EVENT sau khi đã khóa loading (Đảm bảo không bị double log)
      if (bannerAdType == BannerAdType.bannerSplash) {
        FirebaseHelper.logEventName(FirebaseHelper.banner_splash_start_load,
            param: Get.currentRoute);
      }

      // 6. Thực hiện các tác vụ async (Lấy kích thước ad)
      final width = MediaQuery.of(Get.context!).size.width.truncate();
      final AnchoredAdaptiveBannerAdSize? size =
          await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);

      if (size == null) {
        isLoadingBanner[bannerAdType] = false;
        return;
      }

      var adRequest = const AdRequest();

      BannerAd(
        adUnitId: bannerAdType.adId,
        request: adRequest,
        size: size,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            isLoadingBanner[bannerAdType] = false;
            _failedBannerLoadAttempts[bannerAdType] = 0;
            BannerAd loadedAd = ad as BannerAd;

            // Kiểm tra xem có ai đang đợi trong hàng chờ không
            if (_callbackBannerAds[bannerAdType]?.isNotEmpty == true) {
              // Lấy callback đầu tiên ra và thực thi
              final callback = _callbackBannerAds[bannerAdType]!.removeAt(0);
              callback(loadedAd);

              // Sau khi thực thi callback, nếu vẫn còn người khác đang đợi (queue > 0)
              // thì mới tiến hành load cái tiếp theo sau 2 giây
              if (_callbackBannerAds[bannerAdType]!.isNotEmpty) {
                Future.delayed(const Duration(seconds: 2), () {
                  loadAdmobBannerAd(bannerAdType);
                });
              }
            } else {
              // Không có ai đợi thì lưu vào Map để dùng sau
              bannerAds[bannerAdType] = loadedAd;
            }
          },
          onAdFailedToLoad: (ad, err) {
            isLoadingBanner[bannerAdType] = false;
            ad.dispose();
            AppUtil.showLog(
                "AdmobAdsManager: ${bannerAdType.name} load fail: ${err.message}");

            // Tăng biến đếm retry
            _failedBannerLoadAttempts[bannerAdType] =
                (_failedBannerLoadAttempts[bannerAdType] ?? 0) + 1;

            if (_failedBannerLoadAttempts[bannerAdType]! >=
                maxFailedBannerNativeLoadAttempts) {
              AppUtil.showLog(
                  "AdmobAdsManager: Maximum failed to load attempts reached for ${bannerAdType.name}. Clearing queue.");
              _callbackBannerAds[bannerAdType]?.clear();
              return;
            }

            // Nếu load lỗi nhưng vẫn có người đợi, lấy callback lỗi ra và thử load lại cho người tiếp theo
            if (_callbackBannerAds[bannerAdType]?.isNotEmpty == true) {
              _callbackBannerAds[bannerAdType]!.removeAt(0);
              Future.delayed(const Duration(seconds: 2), () {
                if (_callbackBannerAds[bannerAdType]?.isNotEmpty == true) {
                  loadAdmobBannerAd(bannerAdType);
                }
              });
            }
          },
          onAdImpression: (ad) {
            FirebaseHelper.logAdmobAdImpressionBanner(ad: ad);
            if (bannerAdType == BannerAdType.bannerSplash) {
              FirebaseHelper.logEventName(FirebaseHelper.banner_splash_view,
                  param: Get.currentRoute);
            }
          },
          onPaidEvent: (ad, valueMicros, precision, currencyCode) {
            AppSetting.adImpressionCount++; // Sửa lỗi x = x++
            AdjustHelper.adjustTrackAdRevenue(
                ad: ad,
                valueMicros: valueMicros,
                precision: precision,
                currencyCode: currencyCode,
                adOnScreen: Get.currentRoute.replaceAll('/', ''),
                adUnit: "Banner",
                adImpressionsCount: AppSetting.adImpressionCount);
          },
        ),
      ).load();
    } catch (e) {
      isLoadingBanner[bannerAdType] = false;
      AppUtil.showLog("AdmobAdsManager Error: $e");
    }
  }

  static reloadBannerAdWithType(BannerAdType bannerAdType,
      bool shouldLoadReplaceAd, Function(BannerAd) onLoadAdsSuccess) {
    // 1. Nếu đã có sẵn quảng cáo trong kho (Map)
    if (bannerAds[bannerAdType] != null) {
      onLoadAdsSuccess(bannerAds[bannerAdType]!);
      // Sau khi lấy ra dùng thì xóa trong kho đi
      bannerAds[bannerAdType] = null;
      // Nếu yêu cầu load bù cái mới để dự phòng
      if (shouldLoadReplaceAd) {
        loadAdmobBannerAd(bannerAdType);
      }
    }
    // 2. Nếu trong kho chưa có ad
    else {
      // Đưa callback vào hàng chờ
      _callbackBannerAds[bannerAdType] ??= [];
      _callbackBannerAds[bannerAdType]!.add(onLoadAdsSuccess);
      // Nếu không có tiến trình load nào đang chạy thì mới kích hoạt load mới
      if (isLoadingBanner[bannerAdType] != true) {
        loadAdmobBannerAd(bannerAdType);
      } else {
        AppUtil.showLog(
            "AdmobAdsManager: Đã thêm vào hàng chờ cho ${bannerAdType.name}");
      }
    }
  }

  static reloadNativeAdsWithType(NativeAdType nativeAdType,
      bool shouldLoadReplaceAd, Function(NativeAd) onLoadAdsSuccess) {
    AppUtil.showLog(
        "reloadNativeAdsWithType NativeAd " + nativeAdType.toString());
    bool isShouldLoadNew = shouldLoadReplaceAd;
    if (nativeAds[nativeAdType] != null) {
      onLoadAdsSuccess(nativeAds[nativeAdType]!);
      nativeAds[nativeAdType] = null;
      AppUtil.showLog(
          "reloadNativeAdsWithType NativeAd Valid ${nativeAdType.toString()}");
      if (isShouldLoadNew) {
        loadAdmobNativeAdWithType(nativeAdType);
      }
      if (nativeAdType == NativeAdType.nativeLanguageAd ||
          nativeAdType == NativeAdType.nativeLanguageHighAd) {
        FirebaseHelper.logEventName(FirebaseHelper.reload_native_language_valid,
            param: "");
      }
      if (nativeAdType == NativeAdType.nativeLanguageAltAd ||
          nativeAdType == NativeAdType.nativeLanguageAltHighAd) {
        FirebaseHelper.logEventName(
            FirebaseHelper.reload_native_language_alt_valid,
            param: "");
      }
    } else {
      if (isLoadingNative[nativeAdType] == true) {
        if (nativeAdType == NativeAdType.nativeLanguageAd ||
            nativeAdType == NativeAdType.nativeLanguageHighAd) {
          FirebaseHelper.logEventName("nativeLanguageAd_is_loading", param: "");
        }
        if (nativeAdType == NativeAdType.nativeLanguageAltAd ||
            nativeAdType == NativeAdType.nativeLanguageAltHighAd) {
          FirebaseHelper.logEventName("nativeLanguageAd_is_loading", param: "");
        }
        _callbackNativeAds[nativeAdType] ??= [];
        _callbackNativeAds[nativeAdType]!.add(onLoadAdsSuccess);
        AppUtil.showLog(
            "reloadNativeAdsWithType NativeAd isLoading ${nativeAdType.toString()}");
      } else {
        if (nativeAdType == NativeAdType.nativeLanguageAd ||
            nativeAdType == NativeAdType.nativeLanguageHighAd) {
          FirebaseHelper.logEventName(FirebaseHelper.reload_native_language_new,
              param: "");
        }
        if (nativeAdType == NativeAdType.nativeLanguageAltAd ||
            nativeAdType == NativeAdType.nativeLanguageAltHighAd) {
          FirebaseHelper.logEventName(
              FirebaseHelper.reload_native_language_alt_new,
              param: "");
        }
        AppUtil.showLog(
            "reloadNativeAdsWithType NativeAd load New ${nativeAdType.toString()}");
        _callbackNativeAds[nativeAdType] ??= [];
        _callbackNativeAds[nativeAdType]!.add(onLoadAdsSuccess);
        AppUtil.showLog(
            "reloadNativeAdsWithType NativeAd load New2222 ${nativeAdType.toString()}");
        loadAdmobNativeAdWithType(nativeAdType);
      }
    }
  }

  /// Loads a native ad.
  static loadAdmobNativeAdWithType(NativeAdType nativeAdType) {
    AppUtil.showLog(
        "loadAdmobNativeAdWithType NativeAd ${nativeAdType.toString()}");
    if (AppSetting.isPremiumUser.value || AppSetting.isRemoveAds.value) return;

    // 1. Khởi tạo và Kiểm tra trạng thái loading (Khóa ngay lập tức)
    isLoadingNative[nativeAdType] ??= false;
    nativeAds[nativeAdType] ??= null;

    if (!nativeAds.containsKey(NativeAdType.nativeLanguageHighAd)) {
      nativeAds[NativeAdType.nativeLanguageHighAd] = null;
      nativeAds[NativeAdType.nativeLanguageAltHighAd] = null;
    }
    if (isLoadingNative[nativeAdType] == true) {
      return;
    }
    String nativeAdId = nativeAdType.adId;
    isLoadingNative[nativeAdType] = true;
    NativeAd nativeAd = NativeAd(
        adUnitId: nativeAdId,
        listener: NativeAdListener(
          onAdLoaded: (_nativeAd) {
            AppUtil.showLogFull(
                'loadAdmobNativeAdSmallWithType onAdLoaded nativeAdType: ${nativeAdType.name}');
            _failedNativeLoadAttempts[nativeAdType] = 0;
            NativeAd loadedAd = _nativeAd as NativeAd;

            // Xử lý hàng đợi Callback
            if (_callbackNativeAds[nativeAdType]?.isNotEmpty == true) {
              final callback = _callbackNativeAds[nativeAdType]!.removeAt(0);
              callback(loadedAd);

              // Nếu còn người đợi, load tiếp cái mới sau 2s
              if (_callbackNativeAds[nativeAdType]!.isNotEmpty) {
                Future.delayed(const Duration(seconds: 2), () {
                  loadAdmobNativeAdWithType(nativeAdType);
                });
              }
            } else {
              nativeAds[nativeAdType] = loadedAd;
            }
            switch (nativeAdType) {
              case NativeAdType.nativeLanguageAd:
                FirebaseHelper.logEventName(
                    FirebaseHelper.load_native_language_success,
                    param: Get.currentRoute);
              case NativeAdType.nativeLanguageHighAd:
                FirebaseHelper.logEventName(
                    FirebaseHelper.load_native_language_high_success,
                    param: Get.currentRoute);
              case NativeAdType.nativeLanguageAltAd:
                FirebaseHelper.logEventName(
                    FirebaseHelper.load_native_language_alt_success,
                    param: Get.currentRoute);
              case NativeAdType.nativeLanguageAltHighAd:
                FirebaseHelper.logEventName(
                    FirebaseHelper.load_native_language_high_alt_success,
                    param: Get.currentRoute);
              case NativeAdType.nativeOnboard1Ad:
                FirebaseHelper.logEventName(
                    FirebaseHelper.load_native_onboard1_success,
                    param: Get.currentRoute);
              case NativeAdType.nativeOnboard2Ad:
                FirebaseHelper.logEventName(
                    FirebaseHelper.load_native_onboard2_success,
                    param: Get.currentRoute);
              case NativeAdType.nativeOnboard3Ad:
                FirebaseHelper.logEventName(
                    FirebaseHelper.load_native_onboard2_success,
                    param: Get.currentRoute);
              case NativeAdType.nativeOnboardFull1Ad:
                FirebaseHelper.logEventName(
                    FirebaseHelper.load_native_onboardfull_success,
                    param: Get.currentRoute);
              case NativeAdType.nativeOnboardFull2Ad:
                FirebaseHelper.logEventName(
                    FirebaseHelper.load_native_onboardfull_success,
                    param: Get.currentRoute);
              case NativeAdType.nativeQuestionAd:
                FirebaseHelper.logEventName(
                    FirebaseHelper.load_native_question_success,
                    param: Get.currentRoute);
              case NativeAdType.nativeQuestionAltAd:
                FirebaseHelper.logEventName(
                    FirebaseHelper.load_native_question_alt_success,
                    param: Get.currentRoute);
              default:
            }
          },
          onAdFailedToLoad: (_nativeAd, error) {
            AppUtil.showLogFull(
                'loadAdmobNativeAdSmallWithType onAdFailedToLoad nativeAdType: ${nativeAdType.name}');
            isLoadingNative[nativeAdType] = false;
            _nativeAd.dispose();

            _failedNativeLoadAttempts[nativeAdType] =
                (_failedNativeLoadAttempts[nativeAdType] ?? 0) + 1;

            if (_failedNativeLoadAttempts[nativeAdType]! >=
                maxFailedBannerNativeLoadAttempts) {
              AppUtil.showLogFull(
                  'AdmobAdsManager: Maximum failed to load attempts reached for ${nativeAdType.name}. Clearing queue.');
              _callbackNativeAds[nativeAdType]?.clear();
              return;
            }

            if (_callbackNativeAds[nativeAdType]?.isNotEmpty == true) {
              _callbackNativeAds[nativeAdType]!.removeAt(0);
              Future.delayed(const Duration(seconds: 2), () {
                if (_callbackNativeAds[nativeAdType]?.isNotEmpty == true) {
                  loadAdmobNativeAdWithType(nativeAdType);
                }
              });
            }
          },
          onAdClicked: (_nativeAd) {},
          onAdImpression: (_nativeAd) {
            AppUtil.showLog('AdmobAdsManager NativeAdSmall onAdImpression');
            AppUtil.showLogFull(
                'loadAdmobNativeAdSmallWithType onAdImpression nativeAdType: ${nativeAdType.name}');
            FirebaseHelper.logAdmobAdImpressionNative(ad: _nativeAd);
            if (nativeAdType == NativeAdType.nativeLanguageAd) {
              FirebaseHelper.logEventName(FirebaseHelper.native_language_view,
                  param: "");
            }
            if (nativeAdType == NativeAdType.nativeLanguageHighAd) {
              FirebaseHelper.logEventName(FirebaseHelper.native_language_view,
                  param: "");
            }
            if (nativeAdType == NativeAdType.nativeLanguageAltAd) {
              FirebaseHelper.logEventName(
                  FirebaseHelper.native_language_alt_view,
                  param: "");
            }
            if (nativeAdType == NativeAdType.nativeLanguageAltHighAd) {
              FirebaseHelper.logEventName(
                  FirebaseHelper.native_language_alt_view,
                  param: "");
            }
            if (nativeAdType == NativeAdType.nativeOnboard1Ad) {
              FirebaseHelper.logEventName(
                  FirebaseHelper.native_onboarding_1_view,
                  param: "");
            }
            if (nativeAdType == NativeAdType.nativeOnboard2Ad) {
              FirebaseHelper.logEventName(
                  FirebaseHelper.native_onboarding_3_view,
                  param: "");
            }
            if (nativeAdType == NativeAdType.nativeOnboard3Ad) {
              FirebaseHelper.logEventName(
                  FirebaseHelper.native_onboarding_3_view,
                  param: "");
            }
            if (nativeAdType == NativeAdType.nativeOnboardFull1Ad) {
              FirebaseHelper.logEventName(
                  FirebaseHelper.native_onboarding_full1_view,
                  param: "");
            }
            if (nativeAdType == NativeAdType.nativeOnboardFull2Ad) {
              FirebaseHelper.logEventName(
                  FirebaseHelper.native_onboarding_full2_view,
                  param: "");
            }
            if (nativeAdType == NativeAdType.nativeQuestionAd) {
              FirebaseHelper.logEventName(FirebaseHelper.native_survey_view,
                  param: "");
            }
            if (nativeAdType == NativeAdType.nativeQuestionAltAd) {
              FirebaseHelper.logEventName(FirebaseHelper.native_survey_alt_view,
                  param: "");
            }
          },
          onAdClosed: (_nativeAd) {
            AppUtil.showLog('AdmobAdsManager NativeAdSmall onAdClosed}');
          },
          onAdOpened: (_nativeAd) {
            AppUtil.showLog('AdmobAdsManager NativeAdSmall onAdOpened}');
          },
          onAdWillDismissScreen: (_nativeAd) {
            AppUtil.showLog(
                'AdmobAdsManager NativeAdSmall onAdWillDismissScreen');
          },
          onPaidEvent: (_nativeAd, valueMicros, precision, currencyCode) {
            AppSetting.adImpressionCount++;
            AdjustHelper.adjustTrackAdRevenue(
                ad: _nativeAd,
                valueMicros: valueMicros,
                precision: precision,
                currencyCode: currencyCode,
                adOnScreen: Get.currentRoute.replaceAll('/', ''),
                adUnit: "NativeAd",
                adImpressionsCount: AppSetting.adImpressionCount);
            AdjustHelper.adjustTrackAdRevenue(
                ad: _nativeAd,
                valueMicros: valueMicros * 0.6, // Giả sử điều chỉnh lại doanh thu thực tế nhận được sau khi trừ phí
                precision: precision,
                currencyCode: currencyCode,
                adOnScreen: Get.currentRoute.replaceAll('/', ''),
                adUnit: "NativeAd60%",
                adImpressionsCount: AppSetting.adImpressionCount);
            //(Ad ad, double valueMicros, PrecisionType precision, String currencyCode);
            AppUtil.showLog(
                'AdmobAdsManager NativeAdSmall onPaidEvent valueMicros: ${valueMicros}, currencyCode: ${currencyCode}, precision: ${precision.name}');
            AppUtil.showLog(
                'AdmobAdsManager NativeAdSmall onPaidEvent nativeAd: ${_nativeAd.toString()}');
          },
        ),
        request: const AdRequest(),
        // Styling
        nativeTemplateStyle: NativeTemplateStyle(
            // Required: Choose a template.
            templateType: nativeAdType.templateType,
            // Optional: Customize the ad's style.
            mainBackgroundColor: AppColors.colorBgAds,
            cornerRadius: 15.0,
            callToActionTextStyle: NativeTemplateTextStyle(
                textColor: nativeAdType.ctaTextColor,
                backgroundColor: nativeAdType.ctaColor,
                style: NativeTemplateFontStyle.bold,
                size: 14.0),
            primaryTextStyle: NativeTemplateTextStyle(
                textColor: nativeAdType.primaryTextColor,
                backgroundColor: AppColors.transparent,
                style: NativeTemplateFontStyle.bold,
                size: 14.0),
            secondaryTextStyle: NativeTemplateTextStyle(
                textColor: nativeAdType.secondTextColor,
                backgroundColor: AppColors.transparent,
                style: NativeTemplateFontStyle.normal,
                size: 13.0),
            tertiaryTextStyle: NativeTemplateTextStyle(
                textColor: nativeAdType.secondTextColor,
                backgroundColor: AppColors.transparent,
                style: NativeTemplateFontStyle.normal,
                size: 13.0)))
      ..load();
  }

  //setOverrideImpressionRecording
  static loadAdmobInterstitialAdWithType(InterAdType interAdType) {
    if (AppSetting.isPremiumUser.value || AppSetting.isRemoveAds.value) return;
    // Khởi tạo map nếu chưa có
    isLoadingInter[interAdType] ??= false;
    interAds[interAdType] ??= null;
    if (!isLoadingInter.containsKey(InterAdType.interOpenHighAd)) {
      isLoadingInter[InterAdType.interOpenHighAd] = false;
    }
    // 2. Chặn load trùng (Lock)
    if (isLoadingInter[interAdType] == true) return;
    if (interAds[interAdType] != null)
      return; // Đã có ad sẵn trong kho thì không load thêm

    AppUtil.showLogFull(
        'AdmobAdsManager loadAdmobInterstitialAdWithType interAdType: ${interAdType.name}');
    isLoadingInter[interAdType] = true;
    switch (interAdType) {
      case InterAdType.interOpenAd:
        AdmobAdsManager.timeStartLoadInterOpen = DateTime.now();
        FirebaseHelper.logEventName(FirebaseHelper.inter_open_start_load,
            param: Get.currentRoute);
      case InterAdType.interOpenHighAd:
        FirebaseHelper.logEventName(FirebaseHelper.inter_high_open_start_load,
            param: Get.currentRoute);
      case InterAdType.interHomeAd:
      case InterAdType.interPlayAd:
    }
    InterstitialAd.load(
      adUnitId: interAdType.adId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd insterAd) {
          AppUtil.showLogFull(
              'AdmobAdsManager loadAdmobInterstitialAdWithType onAdLoaded interAdType: ${interAdType.name}');
          interAds[interAdType] = insterAd;
          insterAd.setImmersiveMode(true);
          isLoadingInter[interAdType] = false;

          switch (interAdType) {
            case InterAdType.interOpenAd:
              FirebaseHelper.logEventName(
                  FirebaseHelper.load_inter_splash_success,
                  param: Get.currentRoute);
              var currentTime = DateTime.now();
              var diff = currentTime
                  .difference(AdmobAdsManager.timeStartLoadInterOpen);
              if (diff.inSeconds < 10) {
                FirebaseHelper.logEventName(FirebaseHelper.inter_open_load_10s,
                    param: diff.inSeconds.toString());
              } else if (diff.inSeconds < 20) {
                FirebaseHelper.logEventName(
                    FirebaseHelper.inter_open_load_10s_20s,
                    param: diff.inSeconds.toString());
              } else if (diff.inSeconds < 30) {
                FirebaseHelper.logEventName(
                    FirebaseHelper.inter_open_load_20s_30s,
                    param: diff.inSeconds.toString());
              } else if (diff.inSeconds < 40) {
                FirebaseHelper.logEventName(
                    FirebaseHelper.inter_open_load_30s_40s,
                    param: diff.inSeconds.toString());
              } else if (diff.inSeconds < 50) {
                FirebaseHelper.logEventName(
                    FirebaseHelper.inter_open_load_40s_50s,
                    param: diff.inSeconds.toString());
              } else {
                FirebaseHelper.logEventName(
                    FirebaseHelper.inter_open_load_more_50s,
                    param: diff.inSeconds.toString());
              }
            case InterAdType.interOpenHighAd:
              FirebaseHelper.logEventName(
                  FirebaseHelper.load_inter_splash_high_success,
                  param: Get.currentRoute);
            case InterAdType.interHomeAd:
            case InterAdType.interPlayAd:
          }
        },
        onAdFailedToLoad: (LoadAdError error) {
          isLoadingInter[interAdType] = false;
          interAds[interAdType] = null;

          switch (interAdType) {
            case InterAdType.interOpenAd:
              FirebaseCrashlytics.instance.recordError(
                  error, StackTrace.current,
                  reason: "InterOpen onAdFailedToLoad", fatal: false);
              FirebaseHelper.logEventName(FirebaseHelper.load_inter_splash_fail,
                  param: error.message);
            case InterAdType.interOpenHighAd:
              FirebaseCrashlytics.instance.recordError(
                  error, StackTrace.current,
                  reason: "InterOpenHigh onAdFailedToLoad", fatal: false);
              FirebaseHelper.logEventName(
                  FirebaseHelper.load_inter_splash_high_fail,
                  param: error.message);
            case InterAdType.interHomeAd:
            case InterAdType.interPlayAd:
          }
        },
      ),
    );
  }

  static showAdmobInterstitialAdWithType(InterAdType interAdType,
      {required VoidCallback onNextScreen}) {
    try {
      AppUtil.showLogFull(
          'AdmobAdsManager showAdmobInterstitialAdWithType interAdType: ${interAdType.name}');
      if (AppSetting.isInitRemoteConfig.value) {
        if (interAdType == InterAdType.interHomeAd &&
            !FirebaseRemoteConfigService.getBoolConfigByKey(
                FirebaseRemoteConfigService.inter_home)) {
          onNextScreen();
          return;
        }
        if (interAdType == InterAdType.interPlayAd &&
            !FirebaseRemoteConfigService.getBoolConfigByKey(
                FirebaseRemoteConfigService.inter_play)) {
          onNextScreen();
          return;
        }
      }
      if (AppSetting.appInBackground) {
        if (interAdType == InterAdType.interOpenAd ||
            interAdType == InterAdType.interOpenHighAd) {
          FirebaseHelper.logEventName("Inter_Open_Call_Show_In_Background",
              param: Get.currentRoute);
        } else {
          FirebaseHelper.logEventName("Inter_Call_Show_In_Background",
              param: Get.currentRoute);
        }
        return;
      }
      if (!checkCanShowAdsFull() &&
          interAdType != InterAdType.interOpenAd &&
          interAdType != InterAdType.interOpenHighAd) {
        print('AdmobAdsManager showAdmobInterstitialAd lasttime < 15s');
        AppUtil.showLogFull(
            'AdmobAdsManager showAdmobInterstitialAd lasttime < 15s');
        onNextScreen();
        return;
      }
      if (AppSetting.isPremiumUser.value || AppSetting.isRemoveAds.value) {
        print(
            'AdmobAdsManager showAdmobInterstitialAdWithType isPremiumUser or isRemoveAds');
        AppUtil.showLogFull(
            'AdmobAdsManager showAdmobInterstitialAdWithType isPremiumUser or isRemoveAds');
        onNextScreen();
        return;
      }
      InterstitialAd? interstitialAd;
      if (interAds[interAdType] == null) {
        AppUtil.showLogFull(
            'AdmobAdsManager showAdmobInterstitialAdWithType openInterstitialHighAd is null');
        onNextScreen();
        if (interAdType == InterAdType.interHomeAd ||
            interAdType == InterAdType.interPlayAd) {
          loadAdmobInterstitialAdWithType(interAdType);
        }
        return;
      }
      interstitialAd = interAds[interAdType];
      switch (interAdType) {
        case InterAdType.interOpenAd:
          FirebaseHelper.logEventName(FirebaseHelper.inter_open_call_show,
              param: Get.currentRoute);
        case InterAdType.interOpenHighAd:
          FirebaseHelper.logEventName(FirebaseHelper.inter_open_high_call_show,
              param: Get.currentRoute);
        case InterAdType.interHomeAd:
        case InterAdType.interPlayAd:
      }
      interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (InterstitialAd insterAd) {
          AppUtil.showLogFull(
              'AdmobAdsManager showAdmobInterstitialAd onAdShowedFullScreenContent interAdType: ${interAdType.name}');
          insterAd.onPaidEvent = (ad, valueMicros, precision, currencyCode) {
            AppSetting.adImpressionCount++;
            AdjustHelper.adjustTrackAdRevenue(
                ad: ad,
                valueMicros: valueMicros,
                precision: precision,
                currencyCode: currencyCode,
                adOnScreen: Get.currentRoute.replaceAll('/', ''),
                adUnit: "InterstitialAd",
                adImpressionsCount: AppSetting.adImpressionCount);
            AppUtil.showLog(
                'AdmobAdsManager showAdmobInterstitialAd onPaidEvent: $valueMicros - $precision - $currencyCode - ${ad.responseInfo!.adapterResponses!.length}');
          };
          if (interAdType == InterAdType.interOpenAd ||
              interAdType == InterAdType.interOpenHighAd) {
            FirebaseHelper.logEventName(FirebaseHelper.inter_splash_view,
                param: Get.currentRoute);
          } else {
            FirebaseHelper.logEventName(FirebaseHelper.inters_ad_view,
                param: Get.currentRoute);
          }
          //count để log event user xem ad 5 lần, 10 lần
          Constants.countWatchAdFull = AppSetting().getCountWatchAdFull() ?? 0;
          Constants.countWatchAdFull++;
          AppSetting().saveCountWatchAdFull();
          if (AppSetting().getCountWatchAdFull() == 5) {
            AdjustHelper().trackEventWatch5AdFull();
          } else if (AppSetting().getCountWatchAdFull() == 10) {
            AdjustHelper().trackEventWatch10AdFull();
          }
        },
        onAdDismissedFullScreenContent: (InterstitialAd insterAd) {
          AppUtil.showLogFull(
              'AdmobAdsManager showAdmobInterstitialAd onAdDismissedFullScreenContent interAdType: ${interAdType.name}');
          onNextScreen();
          AppSetting.isShowingFullAd.value = false;
          AdmobAdsManager.lastTimeShowAdsFull = DateTime.now();
          print(
              'AdmobAdsManager showAdmobInterstitialAd onAdDismissedFullScreenContent.');
          interstitialAd = null;
          insterAd.dispose();
          interAds[interAdType] = null;
          switch (interAdType) {
            case InterAdType.interHomeAd:
              loadAdmobInterstitialAdWithType(interAdType);
            case InterAdType.interPlayAd:
              loadAdmobInterstitialAdWithType(interAdType);
            case InterAdType.interOpenAd:
            case InterAdType.interOpenHighAd:
          }
        },
        onAdFailedToShowFullScreenContent:
            (InterstitialAd insterAd, AdError error) {
          AppUtil.showLogFull(
              'AdmobAdsManager showAdmobInterstitialAd onAdFailedToShowFullScreenContent interAdType: ${interAdType.name}');
          onNextScreen();
          print(
              'AdmobAdsManager showAdmobInterstitialAd onAdFailedToShowFullScreenContent: $error');
          AppSetting.isShowingFullAd.value = false;
          insterAd.dispose();
          interstitialAd = null;
          interAds[interAdType] = null;
          switch (interAdType) {
            case InterAdType.interHomeAd:
              loadAdmobInterstitialAdWithType(interAdType);
            case InterAdType.interPlayAd:
              loadAdmobInterstitialAdWithType(interAdType);
            case InterAdType.interOpenAd:
              FirebaseCrashlytics.instance.recordError(
                  error, StackTrace.current,
                  reason: "Inter onAdFailedToShow", fatal: false);
              FirebaseHelper.logEventName(FirebaseHelper.inter_fail_to_show,
                  param: Get.currentRoute);
            case InterAdType.interOpenHighAd:
          }
        },
        onAdImpression: (InterstitialAd insterAd) {
          AppUtil.showLog(
              'AdmobAdsManager showAdmobInterstitialAd onAdImpression');
          // Constants.adImpressionCount++;
          FirebaseHelper.logAdmobAdImpressionInterstitial(ad: insterAd);
        },
      );
      interstitialAd!.show();
      AppSetting.isShowingFullAd.value = true;
    } catch (e) {
      onNextScreen();
      print("error showAdmobInterstitialAdWithType: $e");
    }
  }


}
