import 'dart:async';
import 'dart:convert';
import 'package:adjust_sdk/adjust_config.dart';
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
import 'routes/app_pages.dart';
import 'multillanguage/app_translation.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';

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

  initCommonSDK() {
    initPlatformState();
    subscription = FGBGEvents.instance.stream.listen((event) {
      AppUtil.showLogFull(
          'HomeController FGBGEvents: $event, Get.currentRoute: ${Get.currentRoute}');
      if (event == FGBGType.foreground) {
        AppSetting.appInBackground = false;
      }
      if (event == FGBGType.background) {
        AppSetting.appInBackground = true;
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
        } catch (e) {}
      }
    } catch (e) {}
  }

  initPlatformState() async {
    AdjustConfig config = AdjustConfig(
        AdjustHelper.adjustToken,
        BuildConfig.instance.environment == Environment.DEVELOPMENT
            ? AdjustEnvironment.sandbox
            : AdjustEnvironment.production);

    await EasyAds.instance.initAdjust(config);
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
