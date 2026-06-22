

import 'package:realm/realm.dart';

part 'download_realm_model.realm.dart';

@RealmModel()
class _DownloadRealmModel {
  late ObjectId id;
  late String url;
  late String type;
  late String name;
  late String size;
  late int duration;
  late List<int> thumbnail;
  late String category;
  late DateTime createdAt;
}


