import 'package:cscmobi_app/screens/popup_rename/popup_rename_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/values/app_colors.dart';
import '../../helper/firebase_remote_config_service.dart';

class PopupRenamePage extends GetView<PopupRenameController> {
  @override
  PopupRenameController get controller => Get.isRegistered<PopupRenameController>() ? Get.find<PopupRenameController>() : Get.put(PopupRenameController());
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(left: 40, right: 40),
                decoration: BoxDecoration(color: Colors.transparent),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                        color: AppColors.backgroundColor,
                        borderRadius: BorderRadius.circular(20)),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    width: double.infinity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Enter new name".tr,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColors.main
                          ),
                        ),
                        Container(
                          height: 40,
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 20),
                          padding: EdgeInsets.only(bottom: 7),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundItemColor,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: TextField(
                                    controller: controller.nameController,
                                    focusNode: controller.focusNode,
                                    decoration: InputDecoration(
                                        hintText: 'Enter name'.tr,
                                        border: InputBorder.none,
                                        hintStyle: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.lightGreyColor)),
                                    onChanged: (value) {
                                      controller.onChangeText(value);
                                    },
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.textColor),
                                    textAlignVertical: TextAlignVertical.top,
                                  ).marginOnly(right: 30),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      controller.focusNode.requestFocus();
                                    },
                                    child: Container(
                                      height: double.infinity,
                                      child: Center(
                                        child: Image.asset(
                                          "assets/png/icon_edit.png",
                                          width: 18,
                                          height: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          children: [
                            Flexible(
                              flex: 1,
                              child: GestureDetector(
                                onTap: () {
                                  controller.onSelectSave();
                                },
                                child: Container(
                                  height: 50,
                                  padding: EdgeInsets.only(left: 20, right: 20),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      color: AppColors.main,
                                      borderRadius: BorderRadius.circular(25)
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Save".tr,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.black
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Flexible(
                              flex: 1,
                              child: GestureDetector(
                                onTap: () {
                                  controller.onSelectBack();
                                },
                                child: Container(
                                  height: 50,
                                  padding: EdgeInsets.only(left: 20, right: 20),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      color: AppColors.backgroundColor,
                                      borderRadius: BorderRadius.circular(25),
                                      border: Border.all(
                                          color: AppColors.white,
                                          width: 1
                                      )
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Cancel".tr,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textColor
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 30,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}