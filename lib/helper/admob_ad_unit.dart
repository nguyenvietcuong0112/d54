import 'dart:io';

import '../flavors/build_config.dart';
import '../flavors/environment.dart';

class AdmobAdUnit {
  static String get collapsibleBannerAdUnitId {
    if (BuildConfig.instance.environment == Environment.PRODUCTION) {
      if (Platform.isAndroid) {
        return "";
      } else if (Platform.isIOS) {
        return "";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    } else {
      if (Platform.isAndroid) {
        return "ca-app-pub-3940256099942544/2014213617";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/8388050270";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    }
  }

  static String get bannerAdUnitId {
    if (BuildConfig.instance.environment == Environment.PRODUCTION) {
      if (Platform.isAndroid) {
        return "";
      } else if (Platform.isIOS) {
        return "";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    } else {
      if (Platform.isAndroid) {
        return "ca-app-pub-3940256099942544/6300978111";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/2934735716";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    }
  }

  static String get interstitialAdUnitId {
    if (BuildConfig.instance.environment == Environment.PRODUCTION) {
      if (Platform.isAndroid) {
        return "";
      } else if (Platform.isIOS) {
        return "";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    } else {
      if (Platform.isAndroid) {
        return "ca-app-pub-3940256099942544/8691691433";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/5135589807";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    }
  }

  static String get nativeAdUnitIdWithMedia {
    if (BuildConfig.instance.environment == Environment.PRODUCTION) {
      if (Platform.isAndroid) {
        return "";
      } else if (Platform.isIOS) {
        return "";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    } else {
      if (Platform.isAndroid) {
        return "ca-app-pub-3940256099942544/2247696110";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/3986624511";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    }
  }

  static String get nativeAdUnitIdNoMedia {
    if (BuildConfig.instance.environment == Environment.PRODUCTION) {
      if (Platform.isAndroid) {
        return "";
      } else if (Platform.isIOS) {
        return "";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    } else {
      if (Platform.isAndroid) {
        return "ca-app-pub-3940256099942544/2247696110";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/3986624511";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    }
  }

  static String get nativeAdUnitIdWithMedia2 {
    if (BuildConfig.instance.environment == Environment.PRODUCTION) {
      if (Platform.isAndroid) {
        return "";
      } else if (Platform.isIOS) {
        return "";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    } else {
      if (Platform.isAndroid) {
        return "ca-app-pub-3940256099942544/2247696110";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/3986624511";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    }
  }

  static String get reawardAdUnitId {
    if (BuildConfig.instance.environment == Environment.PRODUCTION) {
      if (Platform.isAndroid) {
        return "";
      } else if (Platform.isIOS) {
        return "";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    } else {
      if (Platform.isAndroid) {
        return "ca-app-pub-3940256099942544/5224354917";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/1712485313";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    }
  }

  static String get openAdUnitId {
    if (BuildConfig.instance.environment == Environment.PRODUCTION) {
      if (Platform.isAndroid) {
        return "";
      } else if (Platform.isIOS) {
        return "";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    } else {
      if (Platform.isAndroid) {
        return "ca-app-pub-3940256099942544/9257395921";
        // return "ca-app-pub-3940256099942544/3419835294";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/5575463023";
        // return "ca-app-pub-3940256099942544/5662855259";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    }
  }
}
