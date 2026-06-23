import 'package:get/get.dart';
import 'package:realm/realm.dart';
import '../core/utils/app_util.dart';
import '../core/values/constants.dart';
import '../models/realm/download_realm_model.dart';

class AppSetting {
  static RxBool isShowingFullAd = false.obs;
  static int adImpressionCount = 1;
  static var isInReviewing = false;
  static String selectedLanguageCode = AppUtil().getUserChoosedLanguage();
  static RxBool isInitRemoteConfig = false.obs;
  static bool shouldShowSound = true;
  static int interval_inter_ad = 15;
  static bool appInBackground = false;
  static var realm = Realm(Configuration.local([]));
  static int time_reload_native_collap = 15;
  static int time_reload_native_all = 15;


  static initAppSetting() {
    realm = Realm(Configuration.local(
      [DownloadRealmModel.schema],
      schemaVersion: 1, // Increase version to let Realm know migration is needed
      migrationCallback: (migration, oldSchemaVersion) {
        if (oldSchemaVersion < 1) {
          // Migration logic here if needed
        }
      },
    ));
  }

  saveCountWatchAdFull() {
    return AppUtil.saveInt(Constants.kCountWatchAdFull, Constants.countWatchAdFull);
  }

  saveCountWatchAdReward() {
    return AppUtil.saveInt(Constants.kCountWatchAdReward, Constants.countWatchAdReward);
  }

  int? getCountWatchAdFull() {
    int? _count = AppUtil.getInt(Constants.kCountWatchAdFull);
    return _count;
  }

  int? getCountWatchAdReward() {
    int? _count = AppUtil.getInt(Constants.kCountWatchAdReward);
    return _count;
  }

  saveFirstTimeOpenApp() {
    return AppUtil.saveString(Constants.kUserOpenAppFirstTime, DateTime.now().toIso8601String());
    // return AppUtil.saveString(Constants.kUserOpenAppFirstTime, DateFormat(Styles.FORMAT_TIMEONLY).format(DateTime.now()));
  }

  DateTime? getFirstTimeOpenApp() {
    DateTime? result;
    String strTMPFirstTime = AppUtil.getString(Constants.kUserOpenAppFirstTime);
    if (strTMPFirstTime.isNotEmpty) {
      result = DateTime.parse(strTMPFirstTime);
    }
    // AppUtil.showLogFull('getFirstTimeOpenApp ${result}');

    return result;
  }


  saveEventRetentionDay1() {
    AppUtil.saveBool(Constants.kUserRetentionDay1, true);
  }

  saveEventRetentionDay3() {
    AppUtil.saveBool(Constants.kUserRetentionDay3, true);
  }

  saveEventRetentionDay7() {
    AppUtil.saveBool(Constants.kUserRetentionDay7, true);
  }

  saveEventRetentionDay14() {
    AppUtil.saveBool(Constants.kUserRetentionDay14, true);
  }

  saveEventRetentionDay20() {
    AppUtil.saveBool(Constants.kUserRetentionDay20, true);
  }

  saveEventRetentionDay30() {
    AppUtil.saveBool(Constants.kUserRetentionDay30, true);
  }

  bool checkSendEventRetentionDay1() {
    bool isSuccess = AppUtil.getBool(Constants.kUserRetentionDay1);
    return isSuccess;
  }

  bool checkSendEventRetentionDay3() {
    bool isSuccess = AppUtil.getBool(Constants.kUserRetentionDay3);
    return isSuccess;
  }

  bool checkSendEventRetentionDay7() {
    bool isSuccess = AppUtil.getBool(Constants.kUserRetentionDay7);
    return isSuccess;
  }

  bool checkSendEventRetentionDay14() {
    bool isSuccess = AppUtil.getBool(Constants.kUserRetentionDay14);
    return isSuccess;
  }

  bool checkSendEventRetentionDay20() {
    bool isSuccess = AppUtil.getBool(Constants.kUserRetentionDay20);
    return isSuccess;
  }

  bool checkSendEventRetentionDay30() {
    bool isSuccess = AppUtil.getBool(Constants.kUserRetentionDay30);
    return isSuccess;
  }
}
