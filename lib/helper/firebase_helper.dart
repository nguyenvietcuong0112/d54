import 'dart:io';
import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/utils/app_util.dart';

class FirebaseHelper {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  static Locale? userLocale = Get.deviceLocale;

  static const EVENT_USER_LOCALE = 'user_locale';

  //Other service
  static const EVENT_CLICK_SERVICE_PLANT = 'click_service_plant';
  static const EVENT_RESULT_SUCCESS_PLANT = 'result_plant';

  static const premium_view = "premium_view";
  static const paywall_view = "paywall_view";
  static const payment_successful = "payment_successful";
  static const payment_failed = "payment_failed";
  static const payment_cancel = "payment_cancel";
  static const payment_restore = "payment_restore";
  static const sale_popup_view = "sale_popup_view";
  static const sale_banner_view = "sale_banner_view";

  static const inters_ad_view = "inters_ad_view";
  static const inter_splash_view = "inter_splash_view";
  static const banner_splash_view = "banner_splash_view";
  static const native_language_view = "native_language_view";

  static const select_language = "select_language";
  static const native_language_alt_view = "native_language_alt_view";
  static const native_onboarding_1_view = "native_onboarding_1_view";
  static const native_onboarding_full1_view = "native_onboarding_full_view";
  static const native_onboarding_full2_view = "native_onboarding_full_view";
  static const native_onboarding_3_view = "native_onboarding_3_view";
  static const native_splash_full_view = "native_splash_full_view";
  static const native_splash_full_high_view = "native_splash_full_high_view";
  static const native_click_full_view = "native_click_full_view";
  static const native_click_full_high_view = "native_click_full_high_view";
  static const question_view = "question_view";
  static const native_survey_view = "native_question_view";
  static const native_survey_alt_view = "native_question_alt_view";
  static const main_view = "main_view";
  static const preview_sound_view = "preview_sound_view";
  static const preview_name_quiz_view = "preview_name_quiz_view";
  static const preview_image_quiz_view = "preview_image_quiz_view";
  static const game_over_view = "game_over_view";
  static const playing_sound_quiz_view = "playing_sound_quiz_view";
  static const playing_name_quiz_view = "playing_name_quiz_view";
  static const playing_image_quiz_view = "playing_image_quiz_view";
  static const wiki_view = "wiki_view";
  static const wiki_detail_view = "wiki_detail_view";
  static const ranking_view = "ranking_view";
  static const soundboard_view = "soundboard_view";
  static const play_sound_view = "play_sound_view";
  static const language_next_view = "language_next_view";
  static const onboard1_view = "onboard1_view";
  static const onboard2_view = "onboard2_view";
  static const onboard3_view = "onboard3_view";
  static const question_next_view = "question_next_view";

  static const show_dialog_no_internet = "show_dialog_no_internet";
  static const show_dialog_no_internet_in_FO = "show_dialog_no_internet_in_FO";

  static const banner_splash_start_load = "banner_splash_start_load";
  static const inter_open_start_load = "inter_open_start_load";
  static const inter_high_open_start_load = "inter_high_open_start_load";
  static const inter_open_load_10s = "inter_open_load_10s";
  static const inter_open_load_10s_20s = "inter_open_load_10s_20s";
  static const inter_open_load_20s_30s = "inter_open_load_20s_30s";
  static const inter_open_load_30s_40s = "inter_open_load_30s_40s";
  static const inter_open_load_40s_50s = "inter_open_load_40s_50s";
  static const inter_open_load_more_50s = "inter_open_load_more_50s";
  static const inter_fail_to_show = "inter_fail_to_show";
  static const inter_open_call_show = "inter_open_call_show";
  static const inter_open_call_show_priority = "inter_open_call_show_priority";
  static const inter_open_high_call_show = "inter_open_high_call_show";
  static const load_inter_splash_success = "load_inter_splash_success";
  static const load_inter_splash_high_success =
      "load_inter_splash_high_success";
  static const load_inter_splash_fail = "load_inter_splash_fail";
  static const load_inter_splash_high_fail = "load_inter_splash_high_fail";
  static const load_native_language_success = "load_native_language_success";
  static const load_native_splash_full_success = "load_native_splash_full_success";
  static const load_native_splash_full_high_success = "load_native_splash_full_high_success";
  static const load_native_click_full_success = "load_native_click_full_success";
  static const load_native_click_full_high_success = "load_native_click_full_high_success";
  static const load_native_language_high_success =
      "load_native_language_high_success";
  static const load_native_language_alt_success =
      "load_native_language_alt_success";
  static const load_native_language_high_alt_success =
      "load_native_language_high_alt_success";
  static const load_native_onboard1_success = "load_native_onboard1_success";
  static const load_native_onboard2_success = "load_native_onboard2_success";
  static const load_native_onboardfull_success =
      "load_native_onboardfull_success";
  static const load_native_question_success = "load_native_question_success";
  static const load_native_question_alt_success =
      "load_native_question_alt_success";
  static const reload_native_splash_full_success =
      "reload_native_splash_full_success";
  static const reload_native_splash_full_high_success =
      "reload_native_splash_full_high_success";
  static const reload_native_click_full_success =
      "reload_native_click_full_success";
  static const reload_native_click_full_high_success =
      "reload_native_click_full_high_success";

  static const reload_native_language_success =
      "reload_native_language_success";
  static const reload_native_language_alt_success =
      "reload_native_language_alt_success";
  static const reload_native_language_high_success =
      "reload_native_language_high_success";
  static const reload_native_language_alt_high_success =
      "reload_native_language_alt_high_success";
  static const reload_native_onboard1_success =
      "reload_native_onboard1_success";
  static const reload_native_onboard2_success =
      "reload_native_onboard2_success";
  static const reload_native_onboardfull1_success =
      "reload_native_onboardfull1_success";
  static const reload_native_onboardfull2_success =
      "reload_native_onboardfull2_success";
  static const reload_native_question_success =
      "reload_native_question_success";
  static const reload_native_question_alt_success =
      "reload_native_question_alt_success";

  static const reload_native_language_valid = "reload_native_language_valid";
  static const reload_native_language_new = "reload_native_language_new";
  static const reload_native_language_alt_valid =
      "reload_native_language_alt_valid";
  static const reload_native_language_alt_new =
      "reload_native_language_alt_new";

  //Event purchase
  static const EVENT_CLICK_PURCHASE_WEEKLY = 'click_purchase_weekly';
  static const EVENT_CLICK_PURCHASE_MONTHLY = 'click_purchase_monthly';
  static const EVENT_CLICK_PURCHASE_YEARLY = 'click_purchase_yearly';
  static const EVENT_CLICK_PURCHASE_YEARLY_SALE = 'click_purchase_yearly_sale';
  static const EVENT_CLICK_PURCHASE_LIFETIME = 'click_purchase_yearly';
  static const EVENT_CLICK_PURCHASE_3MONTHS = 'click_purchase_3months';
  static const EVENT_CLICK_PURCHASE_REMOVE_ADS = 'click_purchase_remove_ads';
  static const EVENT_PURCHASE_SUCCESS_WEEKLY = 'purchase_success_weekly';
  static const EVENT_PURCHASE_SUCCESS_MONTHLY = 'purchase_success_monthly';
  static const EVENT_PURCHASE_SUCCESS_YEARLY = 'purchase_success_yearly';
  static const EVENT_PURCHASE_SUCCESS_YEARLY_SALE = 'purchase_success_yearly';
  static const EVENT_PURCHASE_SUCCESS_LIFETIME = 'purchase_success_yearly';
  static const EVENT_PURCHASE_SUCCESS_3MONTHS = 'purchase_success_3months';
  static const EVENT_PURCHASE_SUCCESS_REMOVE_ADS =
      'purchase_success_remove_ads';
  static const EVENT_PURCHASE_ERROR = 'purchase_error';

  static setUserId(String _userId) {
    analytics.setUserId();
  }

  static setTrackingScreenName(String _screenName) async {
    try {
      FirebaseAnalytics.instance
          .logScreenView(screenName: _screenName, screenClass: _screenName);

      AppUtil.showLog('setTrackingScreenName: $_screenName');
    } catch (e) {
      print("error setTrackingScreenName " + e.toString());
    }
  }

  static logAdmobAdImpressionBanner({required Ad ad}) async {
    /*  await analytics.logAdImpression(
      adFormat: 'Banner',
      adPlatform: 'Admob',
      adSource: ad.responseInfo?.loadedAdapterResponseInfo?.adSourceName,
      adUnitName: ad.adUnitId,
      currency: 'USD',
      // value: revenue
    );*/
  }

  static logAdmobAdImpressionOpenAd({required Ad ad}) async {
/*    await analytics.logAdImpression(
      adFormat: 'OpenAd',
      // adFormat: ad.responseInfo?.responseExtras,
      adPlatform: 'Admob',
      adSource: ad.responseInfo?.loadedAdapterResponseInfo?.adSourceName,
      adUnitName: ad.adUnitId,
      currency: 'USD',
      // value: revenue
    );*/
  }

  static logAdmobAdImpressionNative({required Ad ad}) async {
    /* await analytics.logAdImpression(
      adFormat: 'Native',
      // adFormat: ad.responseInfo?.responseExtras,
      adPlatform: 'Admob',
      adSource: ad.responseInfo?.loadedAdapterResponseInfo?.adSourceName,
      adUnitName: ad.adUnitId,
      currency: 'USD',
      // value: revenue
    );*/
  }

  static logAdmobAdImpressionInterstitial({required InterstitialAd ad}) async {
    /* await analytics.logAdImpression(
      adFormat: 'Interstitial',
      // adFormat: ad.responseInfo?.responseExtras,
      adPlatform: 'Admob',
      adSource: ad.responseInfo?.loadedAdapterResponseInfo?.adSourceName,
      adUnitName: ad.adUnitId,
      currency: 'USD',
      // value: revenue
    );*/
  }

  static logEventName(String eventName, {required String param}) async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: eventName,
        parameters: {
          "param": param,
        },
      );
    } catch (e) {
      print("error logEventName " + e.toString());
    }
  }

  static logEventUserLocale(
      {required String languageCode,
      required String countryCode,
      required String scriptCode}) async {
    await FirebaseAnalytics.instance.logEvent(
      name: EVENT_USER_LOCALE,
      parameters: {
        "language_code": languageCode,
        "country_code": countryCode,
        "script_code": scriptCode,
      },
    );
  }

  static logEventClickPurchaseWeely({required String productId}) async {
    await FirebaseAnalytics.instance.logEvent(
      name: EVENT_CLICK_PURCHASE_WEEKLY,
      parameters: {
        "productID": productId,
        "store": Platform.isIOS ? "Apple" : "Google",
      },
    );
  }

  static logEventClickPurchase3Months({required String productId}) async {
    await FirebaseAnalytics.instance.logEvent(
      name: EVENT_CLICK_PURCHASE_WEEKLY,
      parameters: {
        "productID": productId,
        "store": Platform.isIOS ? "Apple" : "Google",
      },
    );
  }

  static logEventClickPurchaseRemoveAds({required String productId}) async {
    await FirebaseAnalytics.instance.logEvent(
      name: EVENT_CLICK_PURCHASE_REMOVE_ADS,
      parameters: {
        "productID": productId,
        "store": Platform.isIOS ? "Apple" : "Google",
      },
    );
  }

  static logEventClickPurchaseMonthly({required String productId}) async {
    await FirebaseAnalytics.instance.logEvent(
      name: EVENT_CLICK_PURCHASE_MONTHLY,
      parameters: {
        "product_id": productId,
        "store": Platform.isIOS ? "Apple" : "Google",
      },
    );
  }

  static logEventClickPurchaseYearly({
    required String productId,
  }) async {
    await FirebaseAnalytics.instance.logEvent(
      name: EVENT_CLICK_PURCHASE_YEARLY,
      parameters: {
        "productID": productId,
        "store": Platform.isIOS ? "Apple" : "Google",
      },
    );
  }

  static logEventClickPurchaseYearlySale({
    required String productId,
  }) async {
    await FirebaseAnalytics.instance.logEvent(
      name: EVENT_CLICK_PURCHASE_YEARLY,
      parameters: {
        "productID": productId,
        "store": Platform.isIOS ? "Apple" : "Google",
      },
    );
  }

  static logEventClickPurchaseLifetime({
    required String productId,
  }) async {
    await FirebaseAnalytics.instance.logEvent(
      name: EVENT_CLICK_PURCHASE_YEARLY,
      parameters: {
        "productID": productId,
        "store": Platform.isIOS ? "Apple" : "Google",
      },
    );
  }
}
