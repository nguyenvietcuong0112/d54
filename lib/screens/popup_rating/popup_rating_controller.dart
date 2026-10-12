import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/base/base_controller.dart';
import '../../helper/firebase_helper.dart';
import '../../helper/rating_helper.dart';

class PopupRatingController extends BaseController {
  RxDouble currentStar = 0.0.obs;
  RxBool isRatedThankYou = false.obs;
  Timer? _autoCloseTimer;

  static const String androidPackageName = "com.video.downloader.fastsave";

  @override
  void onInit() {
    super.onInit();
    currentStar.value = 0.0;
    isRatedThankYou.value = false;
    FirebaseHelper.setTrackingScreenName("RatingPopup");
  }

  @override
  void onClose() {
    _autoCloseTimer?.cancel();
    super.onClose();
  }

  void onSelectStar(int star) {
    currentStar.value = star.toDouble();
    if (star >= 4) {
      onSelectHighRating();
    } else {
      onSelectLowRating();
    }
  }

  /// Nếu user chọn 4 hoặc 5 sao: chuyển thẳng vào store luôn để rating
  void onSelectHighRating() async {
    RatingHelper.setRated(true);
    _autoCloseTimer?.cancel();
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    try {
      if (Platform.isAndroid) {
        final marketUri = Uri.parse("market://details?id=$androidPackageName");
        if (await canLaunchUrl(marketUri)) {
          await launchUrl(marketUri, mode: LaunchMode.externalApplication);
          return;
        }
      }
      final webUri = Uri.parse("https://play.google.com/store/apps/details?id=$androidPackageName");
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Error opening store: $e");
    }
  }

  /// Nếu user chọn từ 3 sao trở xuống: hiện "Cảm ơn" (hiện 2s rồi tự ẩn)
  void onSelectLowRating() {
    RatingHelper.setRated(true);
    isRatedThankYou.value = true;
    _autoCloseTimer?.cancel();
    _autoCloseTimer = Timer(const Duration(seconds: 2), () {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    });
  }

  /// Nếu user click "No" / "Close": đóng popup Rating
  void onSelectClose() {
    _autoCloseTimer?.cancel();
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}