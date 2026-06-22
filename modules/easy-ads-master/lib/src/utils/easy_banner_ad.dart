import 'dart:async';

import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';

class EasyBannerAd extends StatefulWidget {
  final AdNetwork adNetwork;
  final AdSize? adSize;
  final String adId;
  final bool isCollapsible;

  const EasyBannerAd({
    this.adNetwork = AdNetwork.admob,
    this.adSize,
    required this.adId,
    this.isCollapsible = false,
    Key? key,
  }) : super(key: key);

  @override
  State<EasyBannerAd> createState() => _EasyBannerAdState();
}

class _EasyBannerAdState extends State<EasyBannerAd> {
  EasyAdBase? _bannerAd;

  StreamSubscription? _streamSubscription;

  @override
  Widget build(BuildContext context) => _bannerAd?.show() ?? const SizedBox();

  AdSize? adSize;
  Future<void> _initAd() async {
    if (adSize != null) {
      return;
    }
    if (widget.adSize != null) {
      adSize = widget.adSize!;
    } else {
      adSize = EasyAds.instance.adSize;
    }
    _bannerAd = EasyAds.instance.createBanner(
      adNetwork: widget.adNetwork,
      adSize: adSize,
      adId: widget.adId,
      isCollapsible: widget.isCollapsible,
    );
    _bannerAd?.load();
    _streamSubscription = EasyAds.instance.onEvent.listen((event) {
      if (event.adUnitType == AdUnitType.banner) {
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    _initAd();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _streamSubscription?.cancel();
    super.dispose();
  }
}
