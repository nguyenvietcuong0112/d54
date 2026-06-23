import '../../core/utils/app_util.dart';
import '../../flavors/build_config.dart';
import '../../flavors/environment.dart';
import 'ad_id.dart';
import 'ad_id_name.dart';

extension AdIdEx on String {
  String get getId {
    final env = BuildConfig.instance.environment == Environment.PRODUCTION ? 'prod' : 'dev';
    String? id = myAdsId[env]?[this];
    return id ?? "null";
  }
}
