import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

abstract class BaseController extends GetxController {
  RxBool isNativeAdLoaded = false.obs;
  NativeAd? nativeAd;

  NativeAd? nativeAdAlt;
  RxBool isNativeAltAdLoaded = false.obs;

  BannerAd? bannerAd;
  RxBool isBannerAdLoaded = false.obs;

  BannerAd? collapBannerAd;
  RxBool isCollappAdLoaded = false.obs;

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    if (nativeAd != null) {
      nativeAd!.dispose();
    }
    if (nativeAdAlt != null) {
      nativeAdAlt!.dispose();
    }
    if (bannerAd != null) {
      bannerAd!.dispose();
    }
    if (collapBannerAd != null) {
      collapBannerAd!.dispose();
    }
  }
}
