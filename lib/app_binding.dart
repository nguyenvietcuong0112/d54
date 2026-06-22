import 'package:cscmobi_app/core/network/network_controller.dart';
import 'package:get/get.dart';

import 'api_rest/api_repository.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() async {
    Get.put(NetworkController(), permanent: true);
    Get.put(ApiRepository(), permanent: true);
  }
}
