import 'dart:async';
import 'dart:convert';
import 'package:adjust_sdk/adjust.dart';
import 'package:adjust_sdk/adjust_attribution.dart';
import 'package:adjust_sdk/adjust_config.dart';
import 'package:adjust_sdk/adjust_event_failure.dart';
import 'package:adjust_sdk/adjust_event_success.dart';
import 'package:adjust_sdk/adjust_session_failure.dart';
import 'package:adjust_sdk/adjust_session_success.dart';
import 'package:cscmobi_app/helper/firebase_remote_config_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:get/get.dart';

import 'Utils/app_setting.dart';
import 'api_rest/api_repository.dart';
import 'app_binding.dart';
import 'core/utils/app_util.dart';
import 'core/values/app_colors.dart';
import 'core/values/constants.dart';
import 'core/widget/widgets.dart';

import '/flavors/build_config.dart';
import '/flavors/env_config.dart';
import 'flavors/environment.dart';
import 'helper/adjust_helper.dart';
import 'helper/admob_app_open_ad_manager.dart';
import 'multillanguage/app_translation.dart';
import 'routes/app_pages.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final EnvConfig _envConfig = BuildConfig.instance.config;
  late StreamSubscription<FGBGType> subscription;

  @override
  void initState() {
    super.initState();
    configLoading();
    AppSetting.initAppSetting();
    initCommonSDK();
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  initCommonSDK(){
    initPlatformState();
    subscription = FGBGEvents.instance.stream.listen((event) {
      AppUtil.showLogFull('HomeController FGBGEvents: $event, Get.currentRoute: ${Get.currentRoute}');
      if (event == FGBGType.foreground) {
        AppSetting.appInBackground = false;
        if (AppSetting.isShowingFullAd.value == false && !Get.currentRoute.contains("splash")) {
          if (FirebaseRemoteConfigService.getBoolConfigByKey(FirebaseRemoteConfigService.resume_open_app)) {
            AdmobAppOpenAdManager.showAdIfAvailable(onCloseAd: () {});
          }
        }
      }
      if (event == FGBGType.background) {
        AppSetting.appInBackground = true;
        // Kích hoạt nạp quảng cáo App Open khi app bắt đầu vào trạng thái Background!
        if (FirebaseRemoteConfigService.getBoolConfigByKey(FirebaseRemoteConfigService.resume_open_app)) {
          AdmobAppOpenAdManager.loadAd();
        }
      }
    });
    Future.delayed(Duration(seconds: 5), () {
      loginGSM();
    });
  }

  loginGSM() async {
    try {
      ApiRepository apiRepository = ApiRepository();
      String result = await apiRepository.requestGSMLogin();
      if (result.isNotEmpty) {
        try {
          Map<String, dynamic> jsonData = json.decode(result);
          if (jsonData.containsKey('accessToken')) {
            String accessToken = jsonData['accessToken'];
            if (accessToken.isNotEmpty) {
              Constants.GSMAccessToken = accessToken;
            }
          }
        } catch (e) {

        }
      }
    } catch (e){
    }
  }

  initPlatformState() async {
    AdjustConfig config = AdjustConfig(
        AdjustHelper.adjustToken,
        BuildConfig.instance.environment == Environment.DEVELOPMENT
            ? AdjustEnvironment.sandbox
            : AdjustEnvironment.production);
    config.logLevel = AdjustLogLevel.verbose;

    config.attributionCallback = (AdjustAttribution attributionChangedData) {
      if (kDebugMode) {
        print('[Adjust]: Attribution changed!');
      }

      if (attributionChangedData.trackerToken != null) {
        print(
            '[Adjust]: Tracker token: ' + attributionChangedData.trackerToken!);
      }
      if (attributionChangedData.trackerName != null) {
        print('[Adjust]: Tracker name: ' + attributionChangedData.trackerName!);
      }
      if (attributionChangedData.campaign != null) {
        print('[Adjust]: Campaign: ' + attributionChangedData.campaign!);
      }
      if (attributionChangedData.network != null) {
        print('[Adjust]: Network: ' + attributionChangedData.network!);
      }
      if (attributionChangedData.creative != null) {
        print('[Adjust]: Creative: ' + attributionChangedData.creative!);
      }
      if (attributionChangedData.adgroup != null) {
        print('[Adjust]: Adgroup: ' + attributionChangedData.adgroup!);
      }
      if (attributionChangedData.clickLabel != null) {
        print('[Adjust]: Click label: ' + attributionChangedData.clickLabel!);
      }
      if (attributionChangedData.costType != null) {
        print('[Adjust]: Cost type: ' + attributionChangedData.costType!);
      }
      if (attributionChangedData.costAmount != null) {
        print('[Adjust]: Cost amount: ' +
            attributionChangedData.costAmount!.toString());
      }
      if (attributionChangedData.costCurrency != null) {
        print(
            '[Adjust]: Cost currency: ' + attributionChangedData.costCurrency!);
      }
    };

    config.sessionSuccessCallback = (AdjustSessionSuccess sessionSuccessData) {
      print('[Adjust]: Session tracking success!');

      if (sessionSuccessData.message != null) {
        print('[Adjust]: Message: ' + sessionSuccessData.message!);
      }
      if (sessionSuccessData.timestamp != null) {
        print('[Adjust]: Timestamp: ' + sessionSuccessData.timestamp!);
      }
      if (sessionSuccessData.adid != null) {
        print('[Adjust]: Adid: ' + sessionSuccessData.adid!);
      }
      if (sessionSuccessData.jsonResponse != null) {
        print('[Adjust]: JSON response: ' + sessionSuccessData.jsonResponse!);
      }
    };

    config.sessionFailureCallback = (AdjustSessionFailure sessionFailureData) {
      print('[Adjust]: Session tracking failure!');

      if (sessionFailureData.message != null) {
        print('[Adjust]: Message: ' + sessionFailureData.message!);
      }
      if (sessionFailureData.timestamp != null) {
        print('[Adjust]: Timestamp: ' + sessionFailureData.timestamp!);
      }
      if (sessionFailureData.adid != null) {
        print('[Adjust]: Adid: ' + sessionFailureData.adid!);
      }
      if (sessionFailureData.willRetry != null) {
        print(
            '[Adjust]: Will retry: ' + sessionFailureData.willRetry.toString());
      }
      if (sessionFailureData.jsonResponse != null) {
        print('[Adjust]: JSON response: ' + sessionFailureData.jsonResponse!);
      }
    };

    config.eventSuccessCallback = (AdjustEventSuccess eventSuccessData) {
      print('[Adjust]: Event tracking success!');

      if (eventSuccessData.eventToken != null) {
        print('[Adjust]: Event token: ' + eventSuccessData.eventToken!);
      }
      if (eventSuccessData.message != null) {
        print('[Adjust]: Message: ' + eventSuccessData.message!);
      }
      if (eventSuccessData.timestamp != null) {
        print('[Adjust]: Timestamp: ' + eventSuccessData.timestamp!);
      }
      if (eventSuccessData.adid != null) {
        print('[Adjust]: Adid: ' + eventSuccessData.adid!);
      }
      if (eventSuccessData.callbackId != null) {
        print('[Adjust]: Callback ID: ' + eventSuccessData.callbackId!);
      }
      if (eventSuccessData.jsonResponse != null) {
        print('[Adjust]: JSON response: ' + eventSuccessData.jsonResponse!);
      }
    };

    config.eventFailureCallback = (AdjustEventFailure eventFailureData) {
      print('[Adjust]: Event tracking failure!');

      if (eventFailureData.eventToken != null) {
        print('[Adjust]: Event token: ' + eventFailureData.eventToken!);
      }
      if (eventFailureData.message != null) {
        print('[Adjust]: Message: ' + eventFailureData.message!);
      }
      if (eventFailureData.timestamp != null) {
        print('[Adjust]: Timestamp: ' + eventFailureData.timestamp!);
      }
      if (eventFailureData.adid != null) {
        print('[Adjust]: Adid: ' + eventFailureData.adid!);
      }
      if (eventFailureData.callbackId != null) {
        print('[Adjust]: Callback ID: ' + eventFailureData.callbackId!);
      }
      if (eventFailureData.willRetry != null) {
        print('[Adjust]: Will retry: ' + eventFailureData.willRetry.toString());
      }
      if (eventFailureData.jsonResponse != null) {
        print('[Adjust]: JSON response: ' + eventFailureData.jsonResponse!);
      }
    };

    config.deferredDeeplinkCallback = (String? uri) {
      print('[Adjust]: Received deferred deeplink: ' + uri!);
    };

    config.conversionValueUpdatedCallback = (num? conversionValue) {
      print('[Adjust]: Received conversion value update: ' +
          conversionValue!.toString());
    };

    config.skad4ConversionValueUpdatedCallback =
        (num? conversionValue, String? coarseValue, bool? lockWindow) {
      print('[Adjust]: Received conversion value update!');
      print('[Adjust]: Conversion value: ' + conversionValue!.toString());
      print('[Adjust]: Coarse value: ' + coarseValue!);
      print('[Adjust]: Lock window: ' + lockWindow!.toString());
    };

    // Add session callback parameters.
    Adjust.addSessionCallbackParameter('scp_foo_1', 'scp_bar');
    Adjust.addSessionCallbackParameter('scp_foo_2', 'scp_value');

    // Add session Partner parameters.
    Adjust.addSessionPartnerParameter('spp_foo_1', 'spp_bar');
    Adjust.addSessionPartnerParameter('spp_foo_2', 'spp_value');

    // Remove session callback parameters.
    Adjust.removeSessionCallbackParameter('scp_foo_1');
    Adjust.removeSessionPartnerParameter('spp_foo_1');

    // Clear all session callback parameters.
    Adjust.resetSessionCallbackParameters();

    // Clear all session partner parameters.
    Adjust.resetSessionPartnerParameters();

    try {
      // Ask for tracking consent.
      Adjust.requestTrackingAuthorizationWithCompletionHandler().then((status) {
        print('[Adjust]: Authorization status update!');
      });
    } catch (_) {}
    // config.coppaCompliantEnabled = true;
    // config.playStoreKidsAppEnabled = true;
    print('[Adjust]: start SDK');
    // Start SDK.
    Adjust.start(config);
  }

  @override
  Widget build(BuildContext context) {
    return
        // AppStateObserver(
        // child:
        FGBGNotifier(
      onEvent: stateAppHandler,
      child: OverlaySupport.global(
        child: GestureDetector(
          child: GetMaterialApp(
            title: _envConfig.appName,
            initialRoute: AppPages.INITIAL,
            initialBinding: AppBinding(),
            getPages: AppPages.routes,
            navigatorObservers: [
              routeObserver,
            ],
            translationsKeys: AppTranslation.translationsKeys,
            locale: Get.deviceLocale,
            fallbackLocale: const Locale('en', 'US'),
            // supportedLocales: _getSupportedLocal(),
            theme: ThemeData(
                primarySwatch: AppColors.colorPrimarySwatch,
                visualDensity: VisualDensity.adaptivePlatformDensity,
                brightness: Brightness.light,
                primaryColor: AppColors.colorPrimary,
                fontFamily: 'AlegreyaSans',
                //checkbox round
                checkboxTheme: CheckboxThemeData(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                scrollbarTheme: ScrollbarThemeData(
                  thumbVisibility: MaterialStateProperty.all<bool>(true),
                )),
            debugShowCheckedModeBanner: false,
            builder: (context, myWidget) {
              myWidget = MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(1.0),
                ),
                child: myWidget ?? Container(),
              );
              myWidget = EasyLoading.init()(context, myWidget);
              return myWidget;
            },
          ),
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
        ),
      ),
    )
        // )
        ;
  }

  List<Locale> _getSupportedLocal() {
    return [
      const Locale('vi', ''), // Vietnam, no country code
      const Locale('en', ''),
      const Locale('bn', ''),
    ];
  }

  void configLoading() {
    EasyLoading.instance
      ..indicatorType = EasyLoadingIndicatorType.ring
      ..loadingStyle = EasyLoadingStyle.light
      // ..indicatorSize = 45.0
      ..radius = 10.0
      // ..progressColor = Colors.yellow
      ..backgroundColor = AppColors.textSub
      ..indicatorColor = AppColors.colorPrimary
      ..textColor = AppColors.colorPrimary
      // ..indicatorColor = hexToColor('#64DEE0')
      // ..textColor = hexToColor('#64DEE0')
      // ..maskColor = Colors.red
      ..userInteractions = true
      ..dismissOnTap = true
      ..maskType = EasyLoadingMaskType.none
      ..animationStyle = EasyLoadingAnimationStyle.scale;
  }

  Future<void> stateAppHandler(FGBGType event) async {
    /*  if (Constants.myUserInfo.value.id.isEmpty) return;

    if (event == FGBGType.foreground) {
      AppUtil.saveLastDateUsage();
    } else if (event == FGBGType.background) {
      try {
        final lastUsageDate = DateFormat(Styles.FORMAT_DATE_AND_TIME)
            .parse(AppUtil.getString(Constants.lastUsage));
        final duration = DateTime.now().difference(lastUsageDate).inSeconds;
        final input = BigDataCloseAppHistoryInput(
          myMedId: Constants.myUserInfo.value.id,
          invisiableTime: DateTime.now(),
          type: OutAppType.INACTIVE.name,
          duration: duration,
        );
        final responseData =
            await ApiGraphQLMutation().requestSaveCloseAppData(input);
        if (responseData.status == Constants.RESPONSE_STATUS_SUCCESS &&
            responseData.data != null) {
          AppUtil.removeLastDateUsage();
          AppUtil.showLog(
              'INACTIVE: saveCloseAppData responseData ${responseData.data}');
        } else {
          AppUtil.removeLastDateUsage();
          AppUtil.showLog('INACTIVE: saveCloseAppData response status false');
        }
      } catch (e) {
        AppUtil.showLog('INACTIVE: saveCloseAppData responseData Error $e');
      }
    }*/
  }
}
