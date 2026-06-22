import 'package:adjust_sdk/adjust.dart';
import 'package:adjust_sdk/adjust_ad_revenue.dart';
import 'package:adjust_sdk/adjust_config.dart';
import 'package:adjust_sdk/adjust_event.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../core/utils/app_util.dart';
import '../flavors/build_config.dart';
import '../flavors/environment.dart';

class AdjustHelper {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  static String adjustToken = '5ws3bsjnd2ww';
  static String adjustEventTokenIAP = '7hfyzb';

  static String adjustEventTokenBuyWeeklySuccess = '';
  static String adjustEventTokenBuyMonthlySuccess = '';
  static String adjustEventTokenBuyYearlySuccess = '';
  static String adjustEventTokenBuyYearlySaleSuccess = '';
  static String adjustEventTokenBuyLifetimeSuccess = '';
  static String adjustEventTokenBuy3MonthsSuccess = '';
  static String adjustEventTokenBuyRemoveAdsSuccess = '';

  static String adjustEventTokenUserDay1Retention = '';
  static String adjustEventTokenUserDay3Retention = '';
  static String adjustEventTokenUserDay7Retention = '';
  static String adjustEventTokenUserDay14Retention = '';
  static String adjustEventTokenUserDay20Retention = '';
  static String adjustEventTokenUserDay30Retention = '';

  static String adjustEventTokenWatch5AdFull = '';
  static String adjustEventTokenWatch10AdFull = '';

  static String adjustEventTokenWatch5AdReward = '';
  static String adjustEventTokenWatch10AdReward = '';

  static String adjustEventTokenTestWork = '';

  trackEventTestWork() {
    AdjustEvent adjustEvent = AdjustEvent(adjustEventTokenTestWork);

    Adjust.trackEvent(adjustEvent);
  }

  trackEventWatch5AdFull() {
    if (BuildConfig.instance.environment == Environment.PRODUCTION) {
      AdjustEvent adjustEvent = AdjustEvent(adjustEventTokenWatch5AdFull);

      Adjust.trackEvent(adjustEvent);
    }
  }

  trackEventWatch10AdFull() {
    if (BuildConfig.instance.environment == Environment.PRODUCTION) {
      AdjustEvent adjustEvent = AdjustEvent(adjustEventTokenWatch10AdFull);

      Adjust.trackEvent(adjustEvent);
    }
  }

  trackEventWatch5AdReward() {
    if (BuildConfig.instance.environment == Environment.PRODUCTION) {
      AdjustEvent adjustEvent = AdjustEvent(adjustEventTokenWatch5AdReward);

      Adjust.trackEvent(adjustEvent);
    }
  }

  trackEventWatch10AdReward() {
    if (BuildConfig.instance.environment == Environment.PRODUCTION) {
      AdjustEvent adjustEvent = AdjustEvent(adjustEventTokenWatch10AdReward);

      Adjust.trackEvent(adjustEvent);
    }
  }

  trackEventUserRetentionDay1() {
    if (BuildConfig.instance.environment == Environment.PRODUCTION) {
      AdjustEvent adjustEvent = AdjustEvent(adjustEventTokenUserDay1Retention);

      Adjust.trackEvent(adjustEvent);
    }
  }

  trackEventUserRetentionDay3() {
    if (BuildConfig.instance.environment == Environment.PRODUCTION) {
      AdjustEvent adjustEvent = AdjustEvent(adjustEventTokenUserDay3Retention);

      Adjust.trackEvent(adjustEvent);
    }
  }

  trackEventUserRetentionDay7() {
    if (BuildConfig.instance.environment == Environment.PRODUCTION) {
      AdjustEvent adjustEvent = AdjustEvent(adjustEventTokenUserDay7Retention);

      Adjust.trackEvent(adjustEvent);
    }
  }

  trackEventUserRetentionDay14() {
    if (BuildConfig.instance.environment == Environment.PRODUCTION) {
      AdjustEvent adjustEvent = AdjustEvent(adjustEventTokenUserDay14Retention);

      Adjust.trackEvent(adjustEvent);
    }
  }

  trackEventUserRetentionDay20() {
    if (BuildConfig.instance.environment == Environment.PRODUCTION) {
      AdjustEvent adjustEvent = AdjustEvent(adjustEventTokenUserDay20Retention);

      Adjust.trackEvent(adjustEvent);
    }
  }

  trackEventUserRetentionDay30() {
    if (BuildConfig.instance.environment == Environment.PRODUCTION) {
      AdjustEvent adjustEvent = AdjustEvent(adjustEventTokenUserDay30Retention);

      Adjust.trackEvent(adjustEvent);
    }
  }
  static adjustTrackAdRevenue({
    required Ad ad,
    required double valueMicros,
    required PrecisionType precision,
    required String currencyCode,
    required String adOnScreen,
    required String adUnit,
    required int adImpressionsCount,
  }) {
    //test ==> không log event ở route splash
    AppUtil.showLogFull('adjustTrackAdRevenue currentRoute: ${Get.currentRoute}');
    // if (Get.currentRoute.contains('splash')) {
    //   AppUtil.showLogFull('adjustTrackAdRevenue in splash ==> don\'t log event');
    //   return;
    // }
    Future.delayed(const Duration(milliseconds: 500), () async {
      // if (BuildConfig.instance.environment == Environment.PRODUCTION) {
      AdjustAdRevenue adjustAdRevenue = new AdjustAdRevenue(AdjustConfig.AdRevenueSourceAdMob);
      // set revenue and currency
      adjustAdRevenue.setRevenue(valueMicros / 1000000, currencyCode);
      // adjustAdRevenue.adRevenuePlacement = adOnScreen;
      adjustAdRevenue.adRevenueUnit = adUnit;
      adjustAdRevenue.adImpressionsCount = adImpressionsCount;
      if (ad.responseInfo != null) {
        AdapterResponseInfo? loadedAdapterResponseInfo = ad.responseInfo!.loadedAdapterResponseInfo;
        if (loadedAdapterResponseInfo != null) {
          adjustAdRevenue.adRevenueUnit = loadedAdapterResponseInfo.adSourceId;
          adjustAdRevenue.adRevenueNetwork = loadedAdapterResponseInfo.adSourceName;
        }
      }
      AppUtil.showLogFull(
          'Adjust.trackAdRevenueNew adUnit: $adUnit, adSourceName: ${adjustAdRevenue.adRevenueNetwork}, value: ${valueMicros / 1000000}, currency: ${currencyCode}');
      Adjust.trackAdRevenueNew(adjustAdRevenue);
      // }
    });
  }




  //0.0000200971875
  //MAX trả vê revenue chính xác rồi, nên ko cần chia cho 1000000 nữa
  // static adjustTrackRevenueMAX({
  //   required MaxAd ad,
  //   // required double revenue,
  //   // required String currencyCode,
  //   // required String adOnScreen,
  //   required String adUnit,
  //   required int adImpressionsCount,
  // }) {
  //   if (BuildConfig.instance.environment == Environment.PRODUCTION) {
  //     AdjustAdRevenue adjustAdRevenue = new AdjustAdRevenue(AdjustConfig.AdRevenueSourceAppLovinMAX);
  //     // set revenue and currency
  //     adjustAdRevenue.setRevenue(ad.revenue, 'USD');
  //     // adjustAdRevenue.setRevenue(revenue, currencyCode);
  //     adjustAdRevenue.adRevenuePlacement = ad.placement;
  //     adjustAdRevenue.adRevenueUnit = ad.adUnitId;
  //     adjustAdRevenue.adImpressionsCount = adImpressionsCount;
  //     // if (ad.responseInfo != null) {
  //     //   // adjustAdRevenue.adRevenueNetwork = ad.responseInfo!.mediationAdapterClassName;
  //     //   AdapterResponseInfo? loadedAdapterResponseInfo = ad.responseInfo!.loadedAdapterResponseInfo;
  //     //   if (loadedAdapterResponseInfo != null) {
  //     // adjustAdRevenue.adImpressionsCount =  ;
  //     adjustAdRevenue.adRevenueUnit = adUnit;
  //     adjustAdRevenue.adRevenueNetwork = ad.networkName;
  //     Adjust.trackAdRevenueNew(adjustAdRevenue);
  //   }
  // }

  //0.0000200971875
  //MAX trả vê revenue chính xác rồi, nên ko cần chia cho 1000000 nữa
  static adjustTrackRevenueMAXEmptyTest({
    required String adUnit,
    required int adImpressionsCount,
  }) {
    AdjustAdRevenue adjustAdRevenue = new AdjustAdRevenue(AdjustConfig.AdRevenueSourceAppLovinMAX);
    // set revenue and currency
    adjustAdRevenue.setRevenue(0, 'USD');
    adjustAdRevenue.adRevenuePlacement = '';
    adjustAdRevenue.adRevenueUnit = '';
    adjustAdRevenue.adImpressionsCount = 0;
    adjustAdRevenue.adRevenueUnit = adUnit;
    adjustAdRevenue.adRevenueNetwork = '';
    Adjust.trackAdRevenueNew(adjustAdRevenue);
  }
}
