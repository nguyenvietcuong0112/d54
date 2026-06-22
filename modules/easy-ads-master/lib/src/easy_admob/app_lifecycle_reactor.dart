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

  bool _onSplashScreen = false;
  bool _isExcludeScreen = false;
  bool _wasInactive = false;

  AppLifecycleReactor({required this.navigatorKey});

  void listenToAppStateChanges() {
    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream
        .forEach((state) => _onAppStateChanged(state));
    WidgetsBinding.instance.addObserver(this);
  }

  void setOnSplashScreen(bool value) {
    _onSplashScreen = value;
  }

  void setIsExcludeScreen(bool value) {
    _isExcludeScreen = value;
  }

  void _onAppStateChanged(AppState appState) async {
    if (_onSplashScreen) {
      return;
    }

    // No need to track background time anymore
    // if (appState == AppState.background) {
    //   print('[AppLifecycleReactor] App went to background');
    // }
    // // Show app open ad when back to foreground
    // else if (appState == AppState.foreground) {
    //   if (!_isExcludeScreen) {
    //     if (navigatorKey.currentContext != null) {
    //       if (EasyAds.instance.isFullscreenAdShowing) {
    //         return;
    //       }
    //       // Load and show app open ad every time (no duration check)
    //       _loadAndShowAppOpenAd();
    //     } else {}
    //   } else {
    //     _isExcludeScreen = false;
    //   }
    // }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Track inactive → resumed path (e.g., recent apps view)
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _wasInactive = true;
    } else if (state == AppLifecycleState.resumed && _wasInactive) {
      _wasInactive = false;
      if (_onSplashScreen) return;
      if (_isExcludeScreen) {
        _isExcludeScreen = false;
        return;
      }

      if (navigatorKey.currentContext != null &&
          !EasyAds.instance.isFullscreenAdShowing &&
          !EasyAds.instance.isManualAppOpenAdShowing) {
        EasyAds.instance.showAppOpenAd(navigatorKey.currentContext!);
      }
    }
  }
}
