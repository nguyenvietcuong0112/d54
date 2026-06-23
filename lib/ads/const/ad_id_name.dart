import '../../flavors/build_config.dart';
import '../../flavors/environment.dart';

class MyAdIdName {
  //app id here

  /// test
  static String get appID {
    final isProd = BuildConfig.instance.environment == Environment.PRODUCTION;
    return isProd
        ? "ca-app-pub-1190669921094353~3938182522"
        : "ca-app-pub-3940256099942544~3347511713";
  }

  //ads id name here
  static const nativeFull = "nativeFull";
  static const nativeLanguage = "nativeLanguage";
  static const nativeLanguageClick = "nativeLanguageClick";
  static const nativeOnboard1Ad = "nativeOnboard1Ad";
  static const nativeOnboardFull1Ad = "nativeOnboardFull1Ad";
  static const nativeOnboardFull2Ad = "nativeOnboardFull2Ad";
  static const nativeOnboard4Ad = "nativeOnboard4Ad";
  static const appOpenResume = "appOpenResume";
  static const interHomeAd = "interHomeAd";
  static const nativeDownloadAd = "nativeDownloadAd";
  static const nativeQuestionAd = "nativeQuestionAd";
  static const nativeHomeAd = "nativeHomeAd";
  static const interSplash = "interSplash";
  static const interSplashHigh = "interSplashHigh";
  static const bannerHome = "bannerHome";
  static const bannerSplash = "bannerSplash";
  static const interPlayAd = "interPlayAd";
}

enum AdType { nativeExpand, nativeCollapse }
