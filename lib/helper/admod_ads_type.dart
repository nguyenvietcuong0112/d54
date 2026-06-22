import 'dart:ui';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/values/app_colors.dart';
import 'admob_helper.dart';

enum NativeAdType {
  nativeLanguageAd,
  nativeLanguageHighAd,
  nativeLanguageAltAd,
  nativeLanguageAltHighAd,
  nativeOnboard1Ad,
  nativeOnboard2Ad,
  nativeOnboard3Ad,
  nativeOnboardFull1Ad,
  nativeOnboardFull2Ad,
  nativeQuestionAd,
  nativeQuestionAltAd,
  nativeHomeAd,
  nativeHome2Ad,
  nativeHomeMediumAd,
  nativeDownloadAd
}

enum InterAdType {
  interOpenAd,
  interOpenHighAd,
  interHomeAd,
  interPlayAd,
}

enum BannerAdType {
  bannerSplash,
  bannerHome,
}

extension NativeAdTypeExtension on NativeAdType {
  String get adId {
    switch(this) {
      case NativeAdType.nativeLanguageAd:
        return AdmobAdHelper.nativeAdLanguageUnitId;
      case NativeAdType.nativeLanguageHighAd:
        return AdmobAdHelper.nativeAdLanguageHighUnitId;
      case NativeAdType.nativeLanguageAltAd:
        return AdmobAdHelper.nativeAdLanguageAltUnitId;
      case NativeAdType.nativeLanguageAltHighAd:
        return AdmobAdHelper.nativeAdLanguageAltHighUnitId;
      case NativeAdType.nativeOnboard1Ad:
        return AdmobAdHelper.nativeAdOnboard1UnitId;
      case NativeAdType.nativeOnboard2Ad:
        return AdmobAdHelper.nativeAdOnboard2UnitId;
      case NativeAdType.nativeOnboard3Ad:
        return AdmobAdHelper.nativeAdOnboard3UnitId;
      case NativeAdType.nativeOnboardFull1Ad:
        return AdmobAdHelper.nativeAdOnboardFull1UnitId;
      case NativeAdType.nativeOnboardFull2Ad:
        return AdmobAdHelper.nativeAdOnboardFull2UnitId;
      case NativeAdType.nativeQuestionAd:
        return AdmobAdHelper.nativeAdSurveyUnitId;
      case NativeAdType.nativeQuestionAltAd:
        return AdmobAdHelper.nativeAdSurveyUnitId;
      case NativeAdType.nativeHomeAd:
        return AdmobAdHelper.nativeAdHomeUnitId;
      case NativeAdType.nativeHome2Ad:
        return AdmobAdHelper.nativeAdHomeUnitId;
      case NativeAdType.nativeHomeMediumAd:
        return AdmobAdHelper.nativeAdHomeUnitId;
      case NativeAdType.nativeDownloadAd:
        return AdmobAdHelper.nativeAdDownloadUnitId;
    }
  }

  TemplateType get templateType {
    switch(this) {
      case NativeAdType.nativeLanguageAd:
        return TemplateType.medium;
      case NativeAdType.nativeLanguageHighAd:
        return TemplateType.medium;
      case NativeAdType.nativeLanguageAltAd:
        return TemplateType.medium;
      case NativeAdType.nativeLanguageAltHighAd:
        return TemplateType.medium;
      case NativeAdType.nativeOnboard1Ad:
        return TemplateType.medium;
      case NativeAdType.nativeOnboard2Ad:
        return TemplateType.medium;
      case NativeAdType.nativeOnboard3Ad:
        return TemplateType.medium;
      case NativeAdType.nativeOnboardFull1Ad:
        return TemplateType.medium2;
      case NativeAdType.nativeOnboardFull2Ad:
        return TemplateType.medium2;
      case NativeAdType.nativeQuestionAd:
        return TemplateType.medium;
      case NativeAdType.nativeQuestionAltAd:
        return TemplateType.medium;
      case NativeAdType.nativeHomeAd:
        return TemplateType.small;
      case NativeAdType.nativeHome2Ad:
        return TemplateType.small2;
      case NativeAdType.nativeHomeMediumAd:
        return TemplateType.medium;
      case NativeAdType.nativeDownloadAd:
        return TemplateType.small;
    }
  }

  Color get primaryTextColor {
    switch(this) {
      case NativeAdType.nativeLanguageAd:
        return AppColors.textColor;
      case NativeAdType.nativeLanguageHighAd:
        return AppColors.textColor;
      case NativeAdType.nativeLanguageAltAd:
        return AppColors.textColor;
      case NativeAdType.nativeLanguageAltHighAd:
        return AppColors.textColor;
      case NativeAdType.nativeOnboard1Ad:
        return AppColors.textColor;
      case NativeAdType.nativeOnboard2Ad:
        return AppColors.textColor;
      case NativeAdType.nativeOnboard3Ad:
        return AppColors.textColor;
      case NativeAdType.nativeOnboardFull1Ad:
        return AppColors.textColor;
      case NativeAdType.nativeOnboardFull2Ad:
        return AppColors.textColor;
      case NativeAdType.nativeQuestionAd:
        return AppColors.textColor;
      case NativeAdType.nativeQuestionAltAd:
        return AppColors.textColor;
      case NativeAdType.nativeHomeAd:
        return AppColors.textColor;
      case NativeAdType.nativeHome2Ad:
        return AppColors.textColor;
      case NativeAdType.nativeHomeMediumAd:
        return AppColors.textColor;
      case NativeAdType.nativeDownloadAd:
        return AppColors.textColor;
    }
  }

  Color get secondTextColor {
    switch(this) {
      case NativeAdType.nativeLanguageAd:
        return AppColors.lightGreyColor;
      case NativeAdType.nativeLanguageHighAd:
        return AppColors.lightGreyColor;
      case NativeAdType.nativeLanguageAltAd:
        return AppColors.lightGreyColor;
      case NativeAdType.nativeLanguageAltHighAd:
        return AppColors.lightGreyColor;
      case NativeAdType.nativeOnboard1Ad:
        return AppColors.lightGreyColor;
      case NativeAdType.nativeOnboard2Ad:
        return AppColors.lightGreyColor;
      case NativeAdType.nativeOnboard3Ad:
        return AppColors.lightGreyColor;
      case NativeAdType.nativeOnboardFull1Ad:
        return AppColors.lightGreyColor;
      case NativeAdType.nativeOnboardFull2Ad:
        return AppColors.lightGreyColor;
      case NativeAdType.nativeQuestionAd:
        return AppColors.lightGreyColor;
      case NativeAdType.nativeQuestionAltAd:
        return AppColors.lightGreyColor;
      case NativeAdType.nativeHomeAd:
        return AppColors.lightGreyColor;
      case NativeAdType.nativeHome2Ad:
        return AppColors.lightGreyColor;
      case NativeAdType.nativeHomeMediumAd:
        return AppColors.lightGreyColor;
      case NativeAdType.nativeDownloadAd:
        return AppColors.lightGreyColor;
    }
  }

  Color get ctaColor {
    switch(this) {
      case NativeAdType.nativeLanguageAd:
        return AppColors.main;
      case NativeAdType.nativeLanguageHighAd:
        return AppColors.main;
      case NativeAdType.nativeLanguageAltAd:
        return AppColors.main;
      case NativeAdType.nativeLanguageAltHighAd:
        return AppColors.main;
      case NativeAdType.nativeOnboard1Ad:
        return AppColors.main;
      case NativeAdType.nativeOnboard2Ad:
        return AppColors.main;
      case NativeAdType.nativeOnboard3Ad:
        return AppColors.main;
      case NativeAdType.nativeOnboardFull1Ad:
        return AppColors.main;
      case NativeAdType.nativeOnboardFull2Ad:
        return AppColors.main;
      case NativeAdType.nativeQuestionAd:
        return AppColors.main;
      case NativeAdType.nativeQuestionAltAd:
        return AppColors.main;
      case NativeAdType.nativeHomeAd:
        return AppColors.main;
      case NativeAdType.nativeHome2Ad:
        return AppColors.main;
      case NativeAdType.nativeHomeMediumAd:
        return AppColors.main;
      case NativeAdType.nativeDownloadAd:
        return AppColors.main;
    }
  }

  Color get ctaTextColor {
    switch(this) {
      case NativeAdType.nativeLanguageAd:
        return AppColors.black;
      case NativeAdType.nativeLanguageHighAd:
        return AppColors.black;
      case NativeAdType.nativeLanguageAltAd:
        return AppColors.black;
      case NativeAdType.nativeLanguageAltHighAd:
        return AppColors.black;
      case NativeAdType.nativeOnboard1Ad:
        return AppColors.black;
      case NativeAdType.nativeOnboard2Ad:
        return AppColors.black;
      case NativeAdType.nativeOnboard3Ad:
        return AppColors.black;
      case NativeAdType.nativeOnboardFull1Ad:
        return AppColors.black;
      case NativeAdType.nativeOnboardFull2Ad:
        return AppColors.black;
      case NativeAdType.nativeQuestionAd:
        return AppColors.black;
      case NativeAdType.nativeQuestionAltAd:
        return AppColors.black;
      case NativeAdType.nativeHomeAd:
        return AppColors.black;
      case NativeAdType.nativeHome2Ad:
        return AppColors.black;
      case NativeAdType.nativeHomeMediumAd:
        return AppColors.black;
      case NativeAdType.nativeDownloadAd:
        return AppColors.black;
    }
  }
}

extension InterAdTypeExtension on InterAdType {
  String get adId {
    switch(this) {
      case InterAdType.interOpenAd:
        return AdmobAdHelper.openInterstitialAdUnitId;
      case InterAdType.interOpenHighAd:
        return AdmobAdHelper.openInterstitialAdHighUnitId;
      case InterAdType.interHomeAd:
        return AdmobAdHelper.interstitialAllAdUnitId;
      case InterAdType.interPlayAd:
        return AdmobAdHelper.interstitialPlayAdUnitId;
    }
  }
}

extension BannerAdTypeExtension on BannerAdType {
  String get adId {
    switch(this) {
      case BannerAdType.bannerSplash:
        return AdmobAdHelper.bannerSplashAdUnitId;
      case BannerAdType.bannerHome:
        return AdmobAdHelper.bannerAllAdUnitId;
    }
  }
}