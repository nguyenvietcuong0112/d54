import 'package:appsflyer_sdk/appsflyer_sdk.dart';

import '../../easy_ads_flutter.dart';

class EasyAppsflyerService {

  factory EasyAppsflyerService() {
    return _instance;
  }
  EasyAppsflyerService._internal();

  static final EasyAppsflyerService _instance = EasyAppsflyerService._internal();

  static late AppsflyerSdk _appsflyerSdk;

  Future<void> initAppsFlyer(AppsflyerSdk sdk) async {
    _appsflyerSdk = sdk;
    await sdk.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
      registerOnDeepLinkingCallback: true,
    );
  }

  void logAdRevenue(
    AdNetwork adNetwork,
    Ad ad,
    double valueMicros,
    String currencyCode,
  ) {
    final adUnitMapping =
        ad.responseInfo?.adapterResponses?.first.adUnitMapping['pubid'] ??
            'Unknown';

    AdRevenueData adRevenueData = AdRevenueData(
      monetizationNetwork: 'Admob',
      mediationNetwork: AFMediationNetwork.googleAdMob.value,
      currencyIso4217Code: currencyCode,
      revenue: valueMicros / 1000000.0,
      additionalParameters: {
        'adUnitId': _extractAdUnitId(adUnitMapping),
      },
    );

    _appsflyerSdk.logAdRevenue(adRevenueData);
  }

  void logAdRevenue100Percent(
      AdNetwork adNetwork,
      Ad ad,
      double valueMicros,
      String currencyCode,
      ) {
    final adUnitMapping =
        ad.responseInfo?.adapterResponses?.first.adUnitMapping['pubid'] ??
            'Unknown';

    final revenue = valueMicros / 1000000.0;

    _appsflyerSdk.logEvent('ad_revenue_100_percent', {
      'af_revenue': revenue,
      'af_currency': currencyCode,
      'ad_unit_id': _extractAdUnitId(adUnitMapping),
      'ad_network': adNetwork.value,
    });
  }

  String _extractAdUnitId(String adUnitMapping) {
    List parts = adUnitMapping.split('/');
    if (parts.length >= 2) {
      return '${parts[0]}/${parts[1]}';
    } else {
      return 'adUnitMapping';
    }
  }
}
