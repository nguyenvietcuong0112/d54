import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cscmobi_app/core/values/app_colors.dart';
import 'package:cscmobi_app/core/anim/ease_in_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_settings_plus/core/open_settings_plus.dart';

class NetworkController extends GetxController {
  bool isConnected = true;
  bool isShowDialogNoInternet = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    _checkInternetConnection();
    _listenToConnectivityChanges();
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }

  Future<void> _checkInternetConnection() async {
    var connectivityResults = await Connectivity().checkConnectivity();
    _handleConnectivityResult(connectivityResults);
  }

  void _listenToConnectivityChanges() {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      _handleConnectivityResult(results);
    });
  }

  void _handleConnectivityResult(List<ConnectivityResult> results) {
    if (results.isEmpty) {
      isConnected = false;
    } else if (results.length == 1) {
      isConnected = !results.contains(ConnectivityResult.none) &&
          !results.contains(ConnectivityResult.bluetooth);
    } else {
      isConnected = true;
    }

    if (isConnected) {
      if (isShowDialogNoInternet) {
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
        isShowDialogNoInternet = false;
      }
    } else {
      showDialogNoInternet();
    }
  }

  void showDialogNoInternet() {
    if (isShowDialogNoInternet) return;
    isShowDialogNoInternet = true;

    Get.dialog(
      Center(
        child: Container(
          width: 320,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ]
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                "assets/png/no_internet.png",
                width: 80,
                height: 80,
              ),
              const SizedBox(height: 20),
              DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                  decoration: TextDecoration.none,
                ),
                child: Text(
                  "Lost Connection".tr,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: AppColors.textColor,
                  height: 1.5,
                  decoration: TextDecoration.none,
                ),
                child: Text(
                  "We can't download videos without internet. Please reconnect and try again.".tr,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              EaseInWidget(
                onTap: () {
                  const OpenSettingsPlusAndroid().wifi();
                },
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.main,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: DefaultTextStyle(
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blackText,
                      decoration: TextDecoration.none,
                    ),
                    child: Text(
                      "Go to setting".tr,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
