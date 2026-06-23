// Copyright 2021 Google LLC
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// ignore_for_file: public_member_api_docs
import 'package:flutter/material.dart';

import '../../easy_ads_flutter.dart';

/// Listens for app foreground events and shows app open ads.
class AppLifecycleReactor with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> navigatorKey;

  bool _onSplashScreen = true;
  bool _isExcludeScreen = false;
  bool _wasInactive = false;

  bool _pausedByAd = false;
  DateTime? _onSplashScreenFalseTime;
  bool _allowAppOpenAd = false;

  AppLifecycleReactor({required this.navigatorKey});

  void setAllowAppOpenAd(bool value) {
    _allowAppOpenAd = value;
  }

  void listenToAppStateChanges() {
    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream
        .forEach((state) => _onAppStateChanged(state));
    WidgetsBinding.instance.addObserver(this);
  }

  void setOnSplashScreen(bool value) {
    _onSplashScreen = value;
    if (!value) {
      _onSplashScreenFalseTime = DateTime.now();
    }
  }

  void setIsExcludeScreen(bool value) {
    _isExcludeScreen = value;
  }

  void _onAppStateChanged(AppState appState) async {
    // Deprecated in favor of didChangeAppLifecycleState
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Track inactive → resumed path (e.g., recent apps view)
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _wasInactive = true;
      if (EasyAds.instance.isFullscreenAdShowing ||
          EasyAds.instance.isManualAppOpenAdShowing) {
        _pausedByAd = true;
      }
    } else if (state == AppLifecycleState.resumed && _wasInactive) {
      _wasInactive = false;
      final wasPausedByAd = _pausedByAd;
      _pausedByAd = false; // Reset

      if (_onSplashScreen) return;
      if (!_allowAppOpenAd) return;

      // Ignore transient resumes within 2 seconds of leaving the splash screen
      if (_onSplashScreenFalseTime != null &&
          DateTime.now().difference(_onSplashScreenFalseTime!).inSeconds < 2) {
        return;
      }

      if (_isExcludeScreen) {
        _isExcludeScreen = false;
        return;
      }

      if (wasPausedByAd) return;

      if (navigatorKey.currentContext != null &&
          !EasyAds.instance.isFullscreenAdShowing &&
          !EasyAds.instance.isManualAppOpenAdShowing) {
        EasyAds.instance.showAppOpenAd(navigatorKey.currentContext!);
      }
    }
  }
}
