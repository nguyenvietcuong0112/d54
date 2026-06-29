import 'dart:async';
import 'dart:ui';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cscmobi_app/core/base/base_controller.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../Utils/app_setting.dart';
import '../../core/utils/app_util.dart';
import '../../core/values/constants.dart';
import '../../helper/firebase_helper.dart';
import '../../helper/firebase_remote_config_service.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import '../../ads/manager/my_ad_id_manager.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/const/ad_id_extension.dart';
import '../../ads/dimens/ad_dimen.dart';
import '../../routes/app_pages.dart';
import '../language/language_controller.dart';
import '../language/language_page.dart';
import '../tabbar/tabbar_controller.dart';
import '../tabbar/tabbar_page.dart';

class SplashController extends BaseController {
  var isNoFirstOpenApp = false.obs;
  static final facebookAppEvents = FacebookAppEvents();
  Timer? timer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isConnected = false;
  RxDouble percentLoading = 0.0.obs;
  Timer? _timer;
  int _value = 0;

  @override
  void onInit() {
    super.onInit();
    EasyAds.instance.appLifecycleReactor?.setOnSplashScreen(true);
    isNoFirstOpenApp.value = AppUtil.getBool("isNoFirstOpenApp");
    _checkInternetConnection();
    _listenToConnectivityChanges();
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
    _timer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      _value++;
      percentLoading.value = _value.toDouble() / 100;
      if (_value >= 100) {
        _timer?.cancel();
        goToHome();
      }
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
      initMobileAdsSDK();
      initFirebase();
      fakeDuration();
    } else {
      AppUtil.showLogFull(
          '_handleConnectivityResult _isConnected: FALSE');
      _timer?.cancel();

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

    // Set up global ad event listener
    EasyAds.instance.onEvent.listen((AdEvent event) {
      AppUtil.showLogFull("EasyAds Event: ${event.type} - ${event.adUnitType}");
      
      // 1. Paid Event (Revenue)
      if (event.type == AdEventType.onPaidEvent) {
        AppSetting.adImpressionCount++;
      }
      
      // 2. Impression Logging
      else if (event.type == AdEventType.onAdImpression) {
        if (event.ad == null) return;
        FirebaseHelper.logAdmobAdImpression(ad: event.ad!);
      }
      
      // 3. Interstitial Show Count
      else if (event.type == AdEventType.adShowed && event.adUnitType == AdUnitType.interstitial) {
        Constants.countWatchAdFull = AppSetting().getCountWatchAdFull() ?? 0;
        Constants.countWatchAdFull++;
        AppSetting().saveCountWatchAdFull();
        if (AppSetting().getCountWatchAdFull() == 5) {
          AdjustHelper().trackEventWatch5AdFull();
        } else if (AppSetting().getCountWatchAdFull() == 10) {
          AdjustHelper().trackEventWatch10AdFull();
        }
      }
    });

    Constants.isMobileAdsSDKInit = true;
    loadAds();
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
    // Deprecated for new ads architecture
  }

  loadAds() async {
    FirebaseHelper.logEventName("Start_load_ads", param: "");
    EasyAds.instance.loadAd();


    if(!isNoFirstOpenApp.value) {
      final bool showLanguageAd = FirebaseRemoteConfigService.getBoolConfigByKey(
          FirebaseRemoteConfigService.native_language);
      final bool showLanguageClickAd = FirebaseRemoteConfigService.getBoolConfigByKey(
          FirebaseRemoteConfigService.native_language_click);

      if (showLanguageAd) {
        EasyAds.instance.preloadNativeAd(
          adId: MyAdIdName.nativeLanguage.getId,
          factoryId: 'nativeMedia',
          height: AdDimen.mediumNativeHeight,
          cacheKey: MyAdIdName.nativeLanguage,
        );
      }
      if (showLanguageClickAd) {
        EasyAds.instance.preloadNativeAd(
          adId: MyAdIdName.nativeLanguageClick.getId,
          factoryId: 'nativeMedia',
          height: AdDimen.mediumNativeHeight,
          cacheKey: MyAdIdName.nativeLanguageClick,
        );
      }
    }
    }


  logEvent() {}

  tryLoadAdNativeLanguage() {
    // Deprecated
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

    bool showInterSplash = FirebaseRemoteConfigService.getBoolConfigByKey(
            FirebaseRemoteConfigService.inter_splash) ||
        FirebaseRemoteConfigService.getBoolConfigByKey(
            FirebaseRemoteConfigService.inter_splash_high);

    if (showInterSplash) {
      EasyAds.instance.showInterstitialAdSplashWith2Id(
        Get.context!,
        interSplashHigh: MyAdIdName.interSplashHigh.getId,
        interSplashAll: MyAdIdName.interSplash.getId,
        adDissmissed: () {
          goNextScreen();
        },
        onFailed: () {
          goNextScreen();
        },
      );
    } else {
      goNextScreen();
    }
  }

  goNextScreen() {
    EasyAds.instance.appLifecycleReactor?.setOnSplashScreen(false);

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
      FirebaseHelper.setTrackingScreenName("SplashScreen");
      await initRemoteConfig();
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
