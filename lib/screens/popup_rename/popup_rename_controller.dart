import 'dart:io';
import 'package:cscmobi_app/core/utils/app_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../core/base/base_controller.dart';
import '../../helper/firebase_helper.dart';
import '../../helper/firebase_remote_config_service.dart';
import 'package:path/path.dart' as p;

class PopupRenameController extends BaseController {
  final TextEditingController nameController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  RxString name = "".obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    FirebaseHelper.setTrackingScreenName("PopupRenameScreen");
    
    String initialName = "";
    if (Get.arguments != null && Get.arguments['name'] != null) {
      initialName = Get.arguments['name'];
    }
    name = initialName.obs;
    nameController.text = name.value;
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    focusNode.dispose();
    nameController.dispose();
    super.onClose();
  }

  String getBaseName(String fileName) {
    return p.basenameWithoutExtension(fileName);
  }

  onSelectBack() {
    Get.back();
  }

  onChangeText(value) {
    name.value = value;
  }

  onSelectSave() async {
    if (name.value.isEmpty) {
      AppUtil.showNormalToast("Name cannot be empty".tr);
      return;
    }
    Get.back(result: {"newName": name.value});
  }
}