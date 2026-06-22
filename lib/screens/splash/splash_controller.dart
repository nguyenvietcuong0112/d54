import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cscmobi_app/core/base/base_controller.dart';
import 'package:cscmobi_app/helper/video_download_helper.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:open_settings_plus/core/open_settings_plus.dart';
import '../../Utils/app_setting.dart';
import '../../core/anim/ease_in_widget.dart';
import '../../core/model/base_model/response_data.dart';
import '../../core/utils/app_setting_util.dart';
import '../../core/utils/app_util.dart';
import '../../core/values/app_colors.dart';
import '../../core/values/constants.dart';
import '../../core/values/styles.dart';
import '../../helper/adjust_helper.dart';
import '../../helper/admob_ads_manager.dart';
import '../../helper/admob_app_open_ad_manager.dart';
import '../../helper/admod_ads_type.dart';
import '../../helper/firebase_helper.dart';
import '../../helper/firebase_remote_config_service.dart';
import '../../routes/app_pages.dart';
import '../language/language_controller.dart';
import '../language/language_page.dart';
import '../tabbar/tabbar_controller.dart';
import '../tabbar/tabbar_page.dart';

class SplashController extends BaseController {
  final int timeShowSplash = 5000;
  final RxBool isShowProgress = false.obs;
  var isNoFirstOpenApp = false.obs;
  static final facebookAppEvents = FacebookAppEvents();
  int maxTimesRetry = 20;
  int currentDelayTry = 1;
  int loadingDelayTime = 2000;
  static bool consentResolved = false; // Biến công khai
  Timer? timer;
  int countRepeat = 0;
  bool _isShowDialogNoInternet = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isConnected = false;
  bool isShowPopupConsent = false;
  RxDouble percentLoading = 0.0.obs;
  Timer? _timer;
  int _value = 0;
  RxBool shouldShowNativeFullAd = false.obs;
  RxBool shouldShowCloseNativeFull = false.obs;

  @override
  void onInit() {
    super.onInit();
    isNoFirstOpenApp.value = AppUtil.getBool("isNoFirstOpenApp");
    _checkInternetConnection();
    _listenToConnectivityChanges();
    fakeDuration();
  }

  @override
  void onReady() {
    logEvent();
    initFacebookSDK();
    logEventRetentionToAdjust();
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    timer?.cancel();
    _timer?.cancel();
    super.onClose();
  }

  initDatabase() {
    print("run init data base");
    AppSetting.initAppSetting();
  }

  fakeDuration() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      _value++;
      if (_value >= 100) _value = 0;
      percentLoading.value = _value.toDouble() / 100;
    });
  }

// Check initial internet connection
  Future<void> _checkInternetConnection() async {
    var connectivityResults = await Connectivity().checkConnectivity();
    _handleConnectivityResult(connectivityResults);
  }

  // Listen for connectivity changes
  void _listenToConnectivityChanges() {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      _handleConnectivityResult(results);
    });
  }

  void _handleConnectivityResult(List<ConnectivityResult> results) {
    if (results.isEmpty) {
      _isConnected = false;
    } else if (results.length == 1) {
      _isConnected = !results.contains(ConnectivityResult.none) &&
          !results.contains(ConnectivityResult.bluetooth);
    } else {
      _isConnected = true;
    }

    if (_isConnected) {
      AppUtil.showLogFull(
          '_handleConnectivityResult _isConnected: TRUE');
      
      //Nếu SDK ads chưa khởi tạo thì check consent form, tránh lặp
      if (!Constants.isMobileAdsSDKInit && !isShowPopupConsent) {
        isShowPopupConsent = true;
        checkShowConsentForm();
        //Khởi tạo luôn firebase và remote config
      }
      initFirebase();
    } else {
      AppUtil.showLogFull(
          '_handleConnectivityResult _isConnected: FALSE');
    }
  }

  initFacebookSDK() async {
    facebookAppEvents.setAutoLogAppEventsEnabled(true);
    facebookAppEvents.setUserID(await AppUtil().getDeviceId());
  }

  initMobileAdsSDK() async {
    if (Constants.isMobileAdsSDKInit)
      return; //Nếu đã khởi tạo rồi thì thôi, tránh khởi tạo trùng

    AppUtil.showLogFull(
        'initMobileAdsSDK isMobileAdsSDKInit: ${Constants.isMobileAdsSDKInit}');

    await MobileAds.instance.initialize().then((initializationStatus) {
      AppUtil.showLogFull(
          'initMobileAdsSDK MobileAds initializationStatus: $initializationStatus');
      initializationStatus.adapterStatuses.forEach((key, value) {
        AppUtil.showLogFull(
            'initMobileAdsSDK MobileAds Adapter status for $key: ${value.description} - ${value.state}');
      });
    });
    AppUtil.showLogFull(
        'initMobileAdsSDK isMobileAdsSDKInit SUCCESS ==> START LOAD OPEN AD: ${Constants.isMobileAdsSDKInit}');
    //add test device
    MobileAds.instance.updateRequestConfiguration(RequestConfiguration(
        testDeviceIds: ['8C0A7507AC13690AAEA8EFB872883FEC']));
    loadAds();
    Constants.isMobileAdsSDKInit = true;
  }

  onSelectCloseAdsFull() {
    if (isNoFirstOpenApp.value) {
      Get.offAllWithController(
          controllerBuilder: () => TabbarController(),
          page: () => TabbarPage(),
          arguments: {"isFromSplash": true});
    } else {
      Get.offWithController(
          controllerBuilder: () => LanguageController(),
          page: () => LanguagePage(),
          arguments: {'isFirstLaunch': true});
    }
  }

  loadAdsHome() {
    AdmobAdsManager.loadAdmobNativeAdWithType(NativeAdType.nativeHomeAd);
  }

  loadAds() async {
    FirebaseHelper.logEventName("Start_load_ads", param: "");

    // 1. Tải Open/Inter High (Độ ưu tiên lớn nhất - chiếm luồng ngay lập tức)
    AdmobAdsManager.loadAdmobInterstitialAdWithType(
        InterAdType.interOpenHighAd);

    // Tải trước Native Language Ad nếu là lần đầu tiên mở app để tăng Show Rate
    if (!isNoFirstOpenApp.value) {
      AdmobAdsManager.loadAdmobNativeAdWithType(NativeAdType.nativeLanguageHighAd);
      AdmobAdsManager.loadAdmobNativeAdWithType(NativeAdType.nativeLanguageAd);
    }

    // 2. Tải Banner Splash cách 800ms
    Future.delayed(const Duration(milliseconds: 800), () {
      AdmobAdsManager.reloadBannerAdWithType(BannerAdType.bannerSplash, false,
          (_bannerAd) {
        if (isClosed) {
          _bannerAd?.dispose();
          return;
        }
        isBannerAdLoaded.value = false;
        bannerAd = _bannerAd;
        isBannerAdLoaded.value = true;
      });
    });
  }

  logEvent() {}

  // Check lại trước khi chuyển sang màn language mà vẫn load chưa được ad native language thì load lại lần nữa
  tryLoadAdNativeLanguage() {
    // Không nạp sẵn bất kỳ ad ngôn ngữ nào tại Splash nữa (đúng triết lý Lazy Load)
  }

  goToHome() {
    String _selectedLanguageCode = AppUtil().getUserChoosedLanguage();
    if (_selectedLanguageCode.isEmpty) {
      _selectedLanguageCode = 'en';
    }
    Locale locale = Locale(_selectedLanguageCode);
    initializeDateFormatting(_selectedLanguageCode);
    Get.updateLocale(locale);
    update();
    if (!AppSetting.isPremiumUser.value) {
      timer = Timer.periodic(Duration(milliseconds: 2000), (Timer t) {
        if (Get.currentRoute == "${AppRoutes.SPLASH}" &&
            AppSetting.appInBackground == false) {
          countRepeat++;

          // --- Splash Interstitial Waterfall ---
          // Nếu High Inter đã thất bại, hoặc quá 4 giây (countRepeat >= 2) mà chưa có ad High
          if ((AdmobAdsManager.isLoadingInter[InterAdType.interOpenHighAd] == false &&
                  AdmobAdsManager.interAds[InterAdType.interOpenHighAd] == null) ||
              (countRepeat >= 2 && AdmobAdsManager.interAds[InterAdType.interOpenHighAd] == null)) {
            // Chỉ phát lệnh nạp bản thường nếu chưa từng nạp
            if (AdmobAdsManager.isLoadingInter[InterAdType.interOpenAd] != true &&
                AdmobAdsManager.interAds[InterAdType.interOpenAd] == null) {
              AdmobAdsManager.loadAdmobInterstitialAdWithType(InterAdType.interOpenAd);
            }
          }

          // --- Tiến hành kiểm tra hiển thị ---
          // Ưu tiên hiển thị ad High trước
          if (AdmobAdsManager.interAds[InterAdType.interOpenHighAd] != null &&
              AppSetting.appInBackground == false) {
            timer!.cancel();
            AdmobAdsManager.showAdmobInterstitialAdWithType(
                InterAdType.interOpenHighAd, onNextScreen: () {
              goNextScreen();
            });
          }
          // Nếu không có High, hiển thị ad thường (nếu đã load xong)
          else if (AdmobAdsManager.interAds[InterAdType.interOpenAd] != null &&
              AppSetting.appInBackground == false) {
            timer!.cancel();
            AdmobAdsManager.showAdmobInterstitialAdWithType(
                InterAdType.interOpenAd, onNextScreen: () {
              goNextScreen();
            });
          }
          // Trường hợp timeout quá lâu không có ad nào (chờ tối đa 8 giây - countRepeat > 4)
          else if (countRepeat > 4 &&
              AdmobAdsManager.isLoadingInter[InterAdType.interOpenHighAd] == false &&
              AdmobAdsManager.isLoadingInter[InterAdType.interOpenAd] == false &&
              AppSetting.appInBackground == false) {
            timer!.cancel();
            goNextScreen();
          }
          // Quá thời gian timeout tuyệt đối (10 giây) -> bỏ qua ad để trải nghiệm người dùng tốt
          else if (countRepeat >= 5) {
            timer!.cancel();
            goNextScreen();
          }
        }
      });
    } else {
      goNextScreen();
      if (timer != null) {
        timer!.cancel();
      }
    }
  }

  goNextScreen() {
    if (isNoFirstOpenApp.value) {
      Get.offAllWithController(
          controllerBuilder: () => TabbarController(),
          page: () => TabbarPage(),
          arguments: {"isFromSplash": true});
    } else {
      Get.offWithController(
          controllerBuilder: () => LanguageController(),
          page: () => LanguagePage(),
          arguments: {'isFirstLaunch': true});
    }
  }

  finishConsentFormAndStartLoadAds() async {
    consentResolved = true;
    // Khởi tạo Google Mobile Ads và load OpenAd or InterAd
    initMobileAdsSDK(); //bắt buộc phải chờ cho SDK ads khởi tạo xong mới được load ads
    AppUtil.showLogFull('SplashController finishConsentFormAndStartLoadAds');
    //Đã xử lý xong consent ==> load ads
    goToHome();
    // processWaitingForConsentAndLoadAd();
  }

  checkShowConsentForm() async {
    try {
      bool consentCompleted = AppSettingUtil().getShowConsentForm();
      AppUtil.showLogFull(
          'checkShowConsentForm consentCompleted: $consentCompleted');

      if (!consentCompleted) {
        try {
          final params = ConsentRequestParameters();
          ConsentInformation.instance.requestConsentInfoUpdate(
            params,
            () async {
              ConsentStatus status =
                  await ConsentInformation.instance.getConsentStatus();
              AppUtil.showLogFull(
                  'checkShowConsentForm ConsentStatus status: $status');

              if (status == ConsentStatus.required) {
                AppUtil.showLogFull(
                    'checkShowConsentForm ConsentStatus ConsentStatus.required ==> loadConsentForm');
                ConsentForm.loadConsentForm(
                  (ConsentForm consentForm) {
                    AppUtil.showLogFull(
                        'checkShowConsentForm ConsentStatus CONSENT FORM CALLED');
                    consentForm.show((FormError? formError) async {
                      //User thao tác vào form rồi thì mới chạy vào đây
                      AppUtil.showLogFull(
                          'checkShowConsentForm ConsentStatus CONSENT FORM SHOWED');
                      if (formError == null) {
                        // Người dùng đã tương tác xong với consent form
                        AppSettingUtil().saveShowConsentForm();
                        // Nếu không cần hiển thị biểu mẫu consent

                        //User thao tác xong consent form
                        // Constants.isConsentDialogShowing = false;

                        AppUtil.showLogFull(
                            'checkShowConsentForm ConsentStatus CONSENT FORM formError');
                        // _initializing = true;
                        // Khởi tạo Google Mobile Ads và tải quảng cáo mở ứng dụng
                        // initMobileAdsSDK();
                      }
                      //Hoàn thành form consent
                      //User thao tác xong consent form
                      // Constants.isConsentDialogShowing = false;
                      AppUtil.showLogFull(
                          'checkShowConsentForm ConsentStatus CONSENT FORM FINISH');
                      // Người dùng đã tương tác xong với consent form
                      AppSettingUtil().saveShowConsentForm();
                      AppUtil.showLogFull(
                          'checkShowConsentForm Form Consent Process done');

                      if (Platform.isIOS) {
                        await showATTPermissionRequest();
                      }
                      finishConsentFormAndStartLoadAds();
                    });
                  },
                  (FormError formError) {
                    AppUtil.showLogFull(
                        'checkShowConsentForm Lỗi khi hiển thị form consent: ${formError.message}');
                    // print("❌ Lỗi khi hiển thị form consent: ${formError.message}");
                    // _initializing = false;
                    //Lỗi consent form khi show
                    // Constants.isConsentDialogShowing = false;
                    AppUtil.showLogFull(
                        'checkShowConsentForm ConsentStatus loadConsentForm ERROR: ${formError.message}');

                    finishConsentFormAndStartLoadAds();
                  },
                );
              } else {
                AppUtil.showLogFull(
                    'checkShowConsentForm ConsentStatus ConsentStatus NOT REQUIRE');
                if (Platform.isIOS) {
                  await showATTPermissionRequest();
                }
                // _initializing = true;

                finishConsentFormAndStartLoadAds();
              }
            },
            (FormError error) {
              AppUtil.showLogFull(
                  'checkShowConsentForm Lỗi khi cập nhật consent info: ${error.message}');
              // _initializing = false;

              finishConsentFormAndStartLoadAds();
            },
          );
        } catch (e) {
          print("❌ Consent handling exception: $e");

          finishConsentFormAndStartLoadAds();
        }
      } else {
        AppUtil.showLogFull('checkShowConsentForm ALREADY show consent');
        // Đã xử lý xong consent
        AppSettingUtil().saveShowConsentForm();
        // Consent đã hoàn tất từ trước
        // Nếu không cần hiển thị biểu mẫu consent
        if (Platform.isIOS) {
          await showATTPermissionRequest();
        }
        // _initializing = true;

        finishConsentFormAndStartLoadAds();
      }
    } catch (_) {}
  }

  Future<void> showATTPermissionRequest() async {
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    if (status == TrackingStatus.notDetermined) {
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
  }

  int differenceInCalendarDays(
      {required DateTime later, required DateTime earlier}) {
    later = DateTime.utc(later.year, later.month, later.day);
    earlier = DateTime.utc(earlier.year, earlier.month, earlier.day);
    return later.difference(earlier).inDays;
  }

  logEventRetentionToAdjust() {
    DateTime? firstTimeOpenApp = AppSetting().getFirstTimeOpenApp();
    if (firstTimeOpenApp == null) {
      AppUtil.showLogFull('getFirstTimeOpenApp NULL ==> Save firsttime');
      AppSetting().saveFirstTimeOpenApp();
    } else {
      AppUtil.showLogFull(
          'getFirstTimeOpenApp ${firstTimeOpenApp.toIso8601String()}');
      int diffDays = differenceInCalendarDays(
          earlier: firstTimeOpenApp, later: DateTime.now());
      AppUtil.showLogFull('getFirstTimeOpenApp diffDays: $diffDays');
      // Các mốc retention: 1, 3, 7, 14, 20, 30
      if (diffDays >= 30) {
        bool check30 = AppSetting().checkSendEventRetentionDay30();
        if (!check30) {
          AppUtil.showLogFull('getFirstTimeOpenApp log event and save 30');
          AdjustHelper().trackEventUserRetentionDay30();
          AppSetting().saveEventRetentionDay30();
        } else {
          AppUtil.showLogFull('getFirstTimeOpenApp already log event 30');
        }
      } else if (diffDays >= 20) {
        bool check20 = AppSetting().checkSendEventRetentionDay20();
        if (!check20) {
          AppUtil.showLogFull('getFirstTimeOpenApp log event and save 20');
          // log event user retention 20 và lưu lại
          AdjustHelper().trackEventUserRetentionDay20();
          AppSetting().saveEventRetentionDay20();
        } else {
          AppUtil.showLogFull('getFirstTimeOpenApp already log event 20');
        }
      } else if (diffDays >= 14) {
        bool check14 = AppSetting().checkSendEventRetentionDay14();
        if (!check14) {
          AppUtil.showLogFull('getFirstTimeOpenApp log event and save 14');
          AdjustHelper().trackEventUserRetentionDay14();
          AppSetting().saveEventRetentionDay14();
        } else {
          AppUtil.showLogFull('getFirstTimeOpenApp already log event 14');
        }
      } else if (diffDays >= 7) {
        bool check7 = AppSetting().checkSendEventRetentionDay7();
        if (!check7) {
          AppUtil.showLogFull('getFirstTimeOpenApp log event and save 7');
          // log event user retention 7 và lưu lại
          AdjustHelper().trackEventUserRetentionDay7();
          AppSetting().saveEventRetentionDay7();
        } else {
          AppUtil.showLogFull('getFirstTimeOpenApp already log event 7');
        }
      } else if (diffDays >= 3) {
        bool check3 = AppSetting().checkSendEventRetentionDay3();
        if (!check3) {
          AppUtil.showLogFull('getFirstTimeOpenApp log event and save 3');
          // log event user retention 3 và lưu lại
          AdjustHelper().trackEventUserRetentionDay3();
          AppSetting().saveEventRetentionDay3();
        } else {
          AppUtil.showLogFull('getFirstTimeOpenApp already log event 3');
        }
      } else if (diffDays >= 1) {
        bool check1 = AppSetting().checkSendEventRetentionDay1();
        if (!check1) {
          AppUtil.showLogFull('getFirstTimeOpenApp log event and save 1');
          // log event user retention 3 và lưu lại
          AdjustHelper().trackEventUserRetentionDay1();
          AppSetting().saveEventRetentionDay1();
        } else {
          AppUtil.showLogFull('getFirstTimeOpenApp already log event 1');
        }
      }
    }
  }

  bool _isFirebaseInitialized = false;

  initFirebase() async {
    if (_isFirebaseInitialized) return;
    _isFirebaseInitialized = true;
    try {
      Firebase.initializeApp().whenComplete(() {
        FirebaseHelper.setTrackingScreenName("SplashScreen");
        initRemoteConfig();
      });
      const fatalError = true;
      // Non-async exceptions
      FlutterError.onError = (errorDetails) {
        if (fatalError) {
          // If you want to record a "fatal" exception
          FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
          // ignore: dead_code
        } else {
          // If you want to record a "non-fatal" exception
          FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
        }
      };
      // Async exceptions
      PlatformDispatcher.instance.onError = (error, stack) {
        if (fatalError) {
          // If you want to record a "fatal" exception
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          // ignore: dead_code
        } else {
          // If you want to record a "non-fatal" exception
          FirebaseCrashlytics.instance.recordError(error, stack);
        }
        return true;
      };
    } catch (e) {
      print("error init fire base" + e.toString());
    }
  }

  initRemoteConfig() async {
    try {
      await FirebaseRemoteConfigService.initFirebaseRemoteConfig();
      AppSetting.isInitRemoteConfig.value = true;
      AppSetting.interval_inter_ad =
          FirebaseRemoteConfigService.getIntConfigByKey(
              FirebaseRemoteConfigService.interval_inter_ad);
    } catch (e) {
      print("error init remote config " + e.toString());
    }
  }
}
