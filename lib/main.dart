import 'dart:async';
import 'dart:io';
import 'package:cscmobi_app/customwidget/ad_loading_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:get/get.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';


import '/flavors/build_config.dart';
import '/flavors/env_config.dart';
import '/flavors/environment.dart';
import 'api_rest/my_http_overrides.dart';
import 'di.dart';
import 'helper/video_download_helper.dart';
import 'helper/firebase_helper.dart';
import 'my_app.dart';
import 'ads/manager/my_ad_id_manager.dart';
import 'ads/const/ad_id_name.dart';
import 'ads/const/ad_id_extension.dart';

final navigatorKey = Get.key;

const bool isProduction = true ;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  VideoDownloadHelper.instance.initialize();
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );
  await Firebase.initializeApp();

  EnvConfig config = isProduction
      ? EnvConfig(
          appName: "App",
          baseUrlAuthen: "",
          baseUrlUtility: "",
          baseUrlGraphQLCore: "",
          shouldCollectCrashLog: true,
        )
      : EnvConfig(
          appName: "App Dev",
          baseUrlAuthen: "",
          baseUrlUtility: "",
          baseUrlGraphQLCore: "",
          shouldCollectCrashLog: true,
        );

  BuildConfig.instantiate(
    envType: isProduction ? Environment.PRODUCTION : Environment.DEVELOPMENT,
    envConfig: config,
  );

  await DenpendencyInjection.init();
  HttpOverrides.global = MyHttpOverrides();

  await _initCrashlytics();
  await _initFirebaseAnalytics();

  // Run the app immediately so the first frame renders without delay, preventing nativePollOnce ANRs!
  runApp(const MyApp());

  // Initialize plugins & ads in the background
  initPlugin();
  _initializeAds();
}

Future<void> _initCrashlytics() async {
  if (kDebugMode) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  } else {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  }

  // Non-async exceptions
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Async exceptions
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}

Future<void> _initFirebaseAnalytics() async {
  await EasyAds.instance.initFirebaseAnalytics(FirebaseHelper.analytics);
}


Future<void> _initializeAds() async {
  try {
    print('🚀 Starting ads initialization...');

    // 1. Request consent
    final params = ConsentRequestParameters(
      consentDebugSettings: ConsentDebugSettings(
        debugGeography: DebugGeography.debugGeographyEea,
      ),
    );

    final consentCompleter = Completer<void>();

    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
          () async {
        try {
          if (await ConsentInformation.instance.isConsentFormAvailable()) {
            await _loadConsentForm();
          }
          print('✅ Consent completed');
        } catch (e) {
          print('⚠️ Consent form error: $e');
        }
        if (!consentCompleter.isCompleted) consentCompleter.complete();
      },
          (error) {
        print('⚠️ Consent error: ${error.message}');
        if (!consentCompleter.isCompleted) consentCompleter.complete();
      },
    );

    // Timeout after 3 seconds so cold start never blocks on slow network
    await consentCompleter.future.timeout(const Duration(seconds: 3), onTimeout: () {
      print('⚠️ Consent request timed out');
    });

    final IAdIdManager adIdManager = MyAdIdManager();

    await EasyAds.instance.initialize(
      adIdManager,
      unityTestMode: true,
      adMobAdRequest: const AdRequest(httpTimeoutMillis: 60000),
      admobConfiguration: RequestConfiguration(testDeviceIds: ['']),
      navigatorKey: navigatorKey,
      loadingSplash: const AdLoadingPage(),
    );

    print('✅ EasyAds initialized');

    await EasyAds.instance.initAdmob(
      appOpenAdUnitId: MyAdIdName.appOpenResume.getId,
    );

    print('✅ AdMob initialized with App Open Ad');
    print('✅ All ads initialization completed successfully');

  } catch (e) {
    print('❌ Ads initialization error: $e');
  }
}

Future<void> _loadConsentForm() async {
  final completer = Completer<void>();

  ConsentForm.loadConsentForm(
        (consentForm) async {
      final status = await ConsentInformation.instance.getConsentStatus();

      if (status == ConsentStatus.required) {
        consentForm.show((formError) async {
          if (formError != null) {
            print('⚠️ Consent form show error: ${formError.message}');
            if (!completer.isCompleted) completer.complete();
            return;
          }
          await _loadConsentForm();
          if (!completer.isCompleted) completer.complete();
        });
      } else {
        if (!completer.isCompleted) completer.complete();
      }
    },
        (formError) {
      print('⚠️ Consent form load error: ${formError.message}');
      if (!completer.isCompleted) completer.complete();
    },
  );

  await completer.future.timeout(const Duration(seconds: 3), onTimeout: () {
    print('⚠️ Consent form loading timed out');
  });
}


Future<void> initPlugin() async {
  if (!Platform.isIOS) return;
  try {
    final TrackingStatus status =
        await AppTrackingTransparency.trackingAuthorizationStatus;
    if (status == TrackingStatus.notDetermined) {
      await Future.delayed(const Duration(milliseconds: 200));
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
  } catch (e) {
    print('⚠️ ATT error: $e');
  }
}

