import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'dart:developer' as developer;

import '../core/values/constants.dart';

class FirebaseRemoteConfigService {
  static FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

  static final String resume_open_app = "resume_open_app";
  static final String banner_splash = "banner_splash";
  static final String inter_splash_high = "inter_splash_high";
  static final String inter_splash = "inter_splash";
  static final String native_language = "native_language";
  static final String native_language_click = "native_language_click";
  static final String native_onboarding_1 = "native_onboarding_1";
  static final String native_onboarding_full_1 = "native_onboarding_full_1";
  static final String native_onboarding_4 = "native_onboarding_4";
  static final String native_onboarding_full_2 = "native_onboarding_full_2";
  static final String native_question = "native_question";
  static final String native_home = "native_home";

  static final String banner_home = "banner_home";
  static final String inter_home = "inter_home";
  static final String native_download = "native_download";
  static final String inter_play = "inter_play";

  static final String interval_inter_ad = "interval_inter_ad";

  static final String title_facebook = "title_facebook";
  static final String title_instagram = "title_instagram";
  static final String title_pinterest = "title_pinterest";
  static final String title_twitter = "title_twitter";
  static final String title_tiktok = "title_tiktok";

  static final String android_app_version = "android_app_version";

  static Future<void> initFirebaseRemoteConfig() async {
    try {
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 2),
          minimumFetchInterval: const Duration(seconds: 60),
        ),
      );
      
      // Thiết lập giá trị mặc định (Defaults) phòng khi Offline hoặc Fetch thất bại
      await remoteConfig.setDefaults({
        "resume_open_app": true,
        "banner_splash": true,
        "inter_splash_high": true,
        "inter_splash": true,
        "native_language": true,
        "native_language_click": true,
        "native_onboarding_1": true,
        "native_onboarding_full_1": true,
        "native_onboarding_4": true,
        "native_onboarding_full_2": true,
        "native_question": true,
        "native_home": true,

        "banner_home": true,
        "inter_home": true,
        "native_download": true,
        "inter_play": true,

        "interval_inter_ad": 15,
        "title_facebook": "Facebook",
        "title_instagram": "Instagram",
        "title_pinterest": "Pinterest",
        "title_twitter": "Twitter",
        "title_tiktok": "TikTok",
        "android_app_version": "1.0.0",
      });

      await remoteConfig.fetchAndActivate();
    } catch (e) {

    }
  }

  static String getStringConfigByKey(String key) {
    return remoteConfig.getString(key);
  }

  static bool getBoolConfigByKey(String key) {
    return remoteConfig.getBool(key);
  }

  static int getIntConfigByKey(String key) {
    return remoteConfig.getInt(key);
  }

  String getAppVersionConfig(){
    if (Platform.isIOS) {
      return remoteConfig.getString(Constants.KeyAppConfigIOS);
    } else {
      return remoteConfig.getString(Constants.KeyAppConfigAndroid);
    }
  }

  String getAdsConfig(){
    if (Platform.isIOS) {
      return remoteConfig.getString(Constants.KeyAppAdsIOS);
    } else {
      return remoteConfig.getString(Constants.KeyAppAdsAndroid);
    }
  }

/* const FirebaseRemoteConfigService({
    required this.firebaseRemoteConfig,
  });

  final FirebaseRemoteConfig firebaseRemoteConfig;

  Future<void> init() async {
    try {
      await firebaseRemoteConfig.ensureInitialized();
      await firebaseRemoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 30),
          minimumFetchInterval: Duration.zero,
        ),
      );
      await firebaseRemoteConfig.fetchAndActivate();
    } on FirebaseException catch (e, st) {
      developer.log(
        'Unable to initialize Firebase Remote Config',
        error: e,
        stackTrace: st,
      );
    }
  }

  getAppConfigByPlatform() {
    if (Platform.isIOS) {
      firebaseRemoteConfig.getString(Constants.KeyAppConfigIOS);
    } else {
      firebaseRemoteConfig.getString(Constants.KeyAppConfigAndroid);
    }
  }*/
}
