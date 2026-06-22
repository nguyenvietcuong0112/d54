import 'dart:io';


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/values/app_colors.dart';
import '../core/utils/app_util.dart';
import '../flavors/build_config.dart';
import '../flavors/environment.dart';

class AdmobAdHelper {
  Widget getNativeAdWidgetSmall({required AdWithView ad, Color? color}) {
    return Container(
      width: Get.width,
      height: 120,
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color != null ? color : AppColors.backgroundItemColor,
      ),
      child: AdWidget(ad: ad),
    );
  }

  Widget getNativeAdWidgetSmall2({required AdWithView ad, Color? color}) {
    return Container(
      width: Get.width,
      height: 200,
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color != null ? color : AppColors.backgroundItemColor,
      ),
      child: AdWidget(ad: ad),
    );
  }

  Widget getNativeAdWidgetFull({required AdWithView ad}) {
    return Container(
      width: Get.width,
      height: Get.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.backgroundItemColor,
      ),
      child: AdWidget(ad: ad),
    );
  }

  Widget getNativeAdWidgetMedium({required AdWithView ad, double? marginValue, Color? color}) {
    return Container(
      width: Get.width,
      height: 220,
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color != null ? color : AppColors.backgroundItemColor,
      ),
      child: AdWidget(ad: ad),
    );
  }

  Widget getNativeAdWidgetInline({required AdWithView ad, double? marginValue, Color? color}) {
    return Container(
      width: Get.width,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color != null ? color : AppColors.backgroundItemColor,
      ),
      child: AdWidget(ad: ad),
    );
  }

  Widget getNativeAdWidgetCollap({required AdWithView ad, double? marginValue, Color? color, required VoidCallback onSelectHide}) {
    return Container(
      width: Get.width,
      height: 300,
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 2),
          )
        ],
        borderRadius: BorderRadius.circular(12),
        color: color != null ? color : Colors.white,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: AdWidget(ad: ad),
          ),
          Positioned(
            top: 5,
            right: 5,
            child: GestureDetector(
              onTap: onSelectHide,
              child: Container(
                width: 40,
                height: 40,
                color: Colors.transparent,
                child: Center(
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.main,
                      border: Border.all(
                        color: AppColors.white,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      // child: AdWidget(ad: ad),
    );
  }

  Widget getBottomBannerAdWidget({bool? isBottom = true, required AdWithView ad}) {
    return Container(
      alignment: Alignment.bottomCenter,
      width: (ad as BannerAd).size.width.toDouble(),
      height: (ad as BannerAd).size.height.toDouble(),
      child: Column(
        children: [
          Container(
            height: 1,
            width: double.infinity,
            color: AppColors.borderColor,
          ),
          Flexible(
            flex: 1,
            child: AdWidget(ad: (ad)),
          )
        ],
      ),
    );
  }

  Widget getBottomCollapBannerAdWidget({bool? isBottom = true, required AdWithView ad}) {
    return Container(
      alignment: Alignment.bottomCenter,
      width: (ad as BannerAd).size.width.toDouble(),
      height: (ad as BannerAd).size.height.toDouble(),
      child: AdWidget(ad: (ad)),
    );
  }

  static String get appUnitId {
    if (BuildConfig.instance.environment == Environment.PRODUCTION) {
      if (Platform.isAndroid) {
        return "ca-app-pub-8871253110135376~3198008003";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/5575463023";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    } else {
      if (Platform.isAndroid) {
        return "ca-app-pub-3940256099942544~3347511713";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/5575463023";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    }
  }


  static String get bannerAllAdUnitId {
    if (BuildConfig.instance.environment == Environment.PRODUCTION) {
      if (Platform.isAndroid) {
        return "ca-app-pub-1190669921094353/3795089593";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/2934735716";
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

  static String get bannerSplashAdUnitId {
    if (BuildConfig.instance.environment == Environment.PRODUCTION) {
      if (Platform.isAndroid) {
        return "ca-app-pub-1190669921094353/1120447494";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/2934735716";
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

  static String get interstitialAllAdUnitId {
    if (BuildConfig.instance.environment == Environment.PRODUCTION) {
      if (Platform.isAndroid) {
        return "ca-app-pub-1190669921094353/8232650755";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/4411468910";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    } else {
      if (Platform.isAndroid) {
        return "ca-app-pub-3940256099942544/1033173712";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/4411468910";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    }
  }

  static String get interstitialPlayAdUnitId {
    if (BuildConfig.instance.environment == Environment.PRODUCTION) {
      if (Platform.isAndroid) {
        return "ca-app-pub-1190669921094353/8855844580";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/4411468910";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    } else {
      if (Platform.isAndroid) {
        return "ca-app-pub-3940256099942544/1033173712";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/4411468910";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    }
  }

  static String get openInterstitialAdUnitId {
    if (BuildConfig.instance.environment == Environment.PRODUCTION) {
      if (Platform.isAndroid) {
        return "ca-app-pub-1190669921094353/6181202480";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/4411468910";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    } else {
      if (Platform.isAndroid) {
        return "ca-app-pub-3940256099942544/1033173712";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/4411468910";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    }
  }

  static String get openInterstitialAdHighUnitId {
    if (BuildConfig.instance.environment == Environment.PRODUCTION) {
      if (Platform.isAndroid) {
        return "ca-app-pub-1190669921094353/8865103351";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/4411468910";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    } else {
      if (Platform.isAndroid) {
        return "ca-app-pub-3940256099942544/1033173712";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/4411468910";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    }
  }

  static String get nativeAdSurveyUnitId {
    if (BuildConfig.instance.environment == Environment.PRODUCTION) {
      if (Platform.isAndroid) {
        return "ca-app-pub-1190669921094353/8562989098";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/2521693316";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    } else {
      if (Platform.isAndroid) {
        return "ca-app-pub-3940256099942544/1044960115";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/2521693316";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    }
  }

  static String get nativeAdHomeUnitId {
    if (BuildConfig.instance.environment == Environment.PRODUCTION) {
      if (Platform.isAndroid) {
        return "ca-app-pub-1190669921094353/4293405749";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/2521693316";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    } else {
      if (Platform.isAndroid) {
        return "ca-app-pub-3940256099942544/1044960115";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/2521693316";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    }
  }

  static String get nativeAdDownloadUnitId {
    if (BuildConfig.instance.environment == Environment.PRODUCTION) {
      if (Platform.isAndroid) {
        return "ca-app-pub-1190669921094353/1168926259";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/2521693316";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    } else {
      if (Platform.isAndroid) {
        return "ca-app-pub-3940256099942544/1044960115";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/2521693316";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    }
  }

  static String get openAdUnitId {
    if (BuildConfig.instance.environment == Environment.PRODUCTION) {
      if (Platform.isAndroid) {
        return "ca-app-pub-1190669921094353/3746610835";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/5575463023";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    } else {
      if (Platform.isAndroid) {
        return "ca-app-pub-3940256099942544/9257395921";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/5575463023";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    }
  }

  static String get nativeAdLanguageUnitId {
    if (BuildConfig.instance.environment == Environment.PRODUCTION) {
      if (Platform.isAndroid) {
        return "ca-app-pub-1190669921094353/3555039140";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/2521693316";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    } else {
      if (Platform.isAndroid) {
        return "ca-app-pub-3940256099942544/1044960115";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/2521693316";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    }
  }

  static String get nativeAdLanguageHighUnitId {
    if (BuildConfig.instance.environment == Environment.PRODUCTION) {
      if (Platform.isAndroid) {
        return "ca-app-pub-1190669921094353/4925858342";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/2521693316";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    } else {
      if (Platform.isAndroid) {
        return "ca-app-pub-3940256099942544/1044960115";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/2521693316";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    }
  }

  static String get nativeAdLanguageAltUnitId {
    if (BuildConfig.instance.environment == Environment.PRODUCTION) {
      if (Platform.isAndroid) {
        return "ca-app-pub-1190669921094353/2189152435";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/2521693316";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    } else {
      if (Platform.isAndroid) {
        return "ca-app-pub-3940256099942544/1044960115";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/2521693316";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    }
  }

  static String get nativeAdLanguageAltHighUnitId {
    if (BuildConfig.instance.environment == Environment.PRODUCTION) {
      if (Platform.isAndroid) {
        return "ca-app-pub-1190669921094353/5299742958";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/2521693316";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    } else {
      if (Platform.isAndroid) {
        return "ca-app-pub-3940256099942544/1044960115";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/2521693316";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    }
  }

  static String get nativeAdOnboard1UnitId {
    if (BuildConfig.instance.environment == Environment.PRODUCTION) {
      if (Platform.isAndroid) {
        final bool isSecond = AppUtil.getBool("isNoFirstOpenApp");
        return isSecond ? "ca-app-pub-1190669921094353/8673531667" : "ca-app-pub-1190669921094353/4676549128";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/2521693316";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    } else {
      if (Platform.isAndroid) {
        return "ca-app-pub-3940256099942544/1044960115";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/2521693316";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    }
  }

  static String get nativeAdOnboard2UnitId {
    if (BuildConfig.instance.environment == Environment.PRODUCTION) {
      if (Platform.isAndroid) {
        final bool isSecond = AppUtil.getBool("isNoFirstOpenApp");
        return isSecond ? "ca-app-pub-1190669921094353/7734334604" : "ca-app-pub-1190669921094353/2673579615";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/2521693316";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    } else {
      if (Platform.isAndroid) {
        return "ca-app-pub-3940256099942544/1044960115";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/2521693316";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    }
  }

  static String get nativeAdOnboard3UnitId {
    if (BuildConfig.instance.environment == Environment.PRODUCTION) {
      if (Platform.isAndroid) {
        return "ca-app-pub-9900730300733887/4744972828";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/2521693316";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    } else {
      if (Platform.isAndroid) {
        return "ca-app-pub-3940256099942544/1044960115";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/2521693316";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    }
  }

  static String get nativeAdOnboardFull1UnitId {
    if (BuildConfig.instance.environment == Environment.PRODUCTION) {
      if (Platform.isAndroid) {
        return "ca-app-pub-1190669921094353/2299695007";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/2521693316";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    } else {
      if (Platform.isAndroid) {
        return "ca-app-pub-3940256099942544/1044960115";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/2521693316";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    }
  }

  static String get nativeAdOnboardFull2UnitId {
    if (BuildConfig.instance.environment == Environment.PRODUCTION) {
      if (Platform.isAndroid) {
        return "ca-app-pub-1190669921094353/4816149928";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/2521693316";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    } else {
      if (Platform.isAndroid) {
        return "ca-app-pub-3940256099942544/1044960115";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/2521693316";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    }
  }
}
