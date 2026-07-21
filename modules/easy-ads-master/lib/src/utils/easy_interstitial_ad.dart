import 'dart:async';

import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';

class EasyInterstitialAd extends StatefulWidget {
  final AdNetwork adNetwork;
  final String adId;
  final void Function()? onShowed;
  final void Function()? onFailed;
  final void Function()? adDismissed;
  final void Function()? onAdImpression;
  final Duration? timeout;

  const EasyInterstitialAd({
    super.key,
    this.adNetwork = AdNetwork.admob,
    required this.adId,
    this.onShowed,
    this.adDismissed,
    this.onFailed,
    this.onAdImpression,
    this.timeout,
  });

  @override
  State<EasyInterstitialAd> createState() => _EasyInterstitialAdState();
}

class _EasyInterstitialAdState extends State<EasyInterstitialAd>
    with WidgetsBindingObserver {
  late final EasyAdBase? _interstitialAd = EasyAds.instance.createInterstitial(
    adNetwork: widget.adNetwork,
    adId: widget.adId,
    immersiveModeEnabled: true,
  );

  StreamSubscription? _streamSubscription;
  Timer? _timeoutTimer;
  bool _isFinished = false;

  void _finishAndPop(void Function()? callback) {
    if (_isFinished) return;
    _isFinished = true;
    _timeoutTimer?.cancel();
    EasyAds.instance.setFullscreenAdShowing(false);
    _streamSubscription?.cancel();
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    callback?.call();
  }

  Future<void> _showAd() => Future.delayed(
        const Duration(seconds: 1),
        () {
          if (_isFinished) return;
          if (_appLifecycleState == AppLifecycleState.resumed) {
            if (mounted) {
              _interstitialAd?.show();
            }
          } else {
            _adFailedToShow = true;
          }
        },
      );

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    EasyAds.instance.setFullscreenAdShowing(true);

    if (widget.timeout != null) {
      _timeoutTimer = Timer(widget.timeout!, () {
        _finishAndPop(widget.onFailed);
      });
    }
    
    _streamSubscription = EasyAds.instance.onEvent.listen((event) {
      if (event.adUnitType == AdUnitType.interstitial &&
          event.adUnitId == widget.adId) {
        switch (event.type) {
          case AdEventType.adLoaded:
            _timeoutTimer?.cancel();
            if (_appLifecycleState == AppLifecycleState.resumed) {
              _showAd();
            } else {
              _adFailedToShow = true;
            }
            break;
          case AdEventType.adShowed:
            _timeoutTimer?.cancel();
            widget.onShowed?.call();
            break;
          case AdEventType.onAdImpression:
            widget.onAdImpression?.call();
            break;
          case AdEventType.adFailedToLoad:
            _finishAndPop(widget.onFailed);
            break;
          case AdEventType.adDismissed:
            _finishAndPop(widget.adDismissed);
            break;
          case AdEventType.adFailedToShow:
            if (_appLifecycleState != AppLifecycleState.resumed) {
              _adFailedToShow = true;
            } else {
              _finishAndPop(widget.onFailed);
            }
            break;
          default:
            break;
        }
      }
    });

    if (_interstitialAd?.isAdLoaded == true) {
      _timeoutTimer?.cancel();
      if (_appLifecycleState == AppLifecycleState.resumed) {
        _showAd();
      } else {
        _adFailedToShow = true;
      }
    } else {
      _interstitialAd?.load();
    }

    super.initState();
  }

  AppLifecycleState _appLifecycleState = AppLifecycleState.resumed;
  bool _adFailedToShow = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appLifecycleState = state;
    if (state == AppLifecycleState.resumed && _adFailedToShow && !_isFinished) {
      _showAd();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _streamSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }
}
