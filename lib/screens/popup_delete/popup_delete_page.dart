import 'package:cscmobi_app/core/values/app_colors.dart';
import 'package:cscmobi_app/screens/popup_delete/popup_delete_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Utils/app_setting.dart';
import '../../helper/admob_helper.dart';
import '../../helper/firebase_remote_config_service.dart';

class PopupDeletePage extends GetView<PopupDeleteController> {
  @override
  PopupDeleteController get controller => Get.isRegistered<PopupDeleteController>() ? Get.find<PopupDeleteController>() : Get.put(PopupDeleteController());
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(left: 40, right: 40),
            decoration: BoxDecoration(
                color: Colors.transparent
            ),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                    color: AppColors.backgroundItemColor,
                    borderRadius: BorderRadius.circular(20)
                ),
                padding: EdgeInsets.only(top: 30, bottom: 20, left: 30, right: 30),
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      controller.title.value.tr,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.main
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      controller.desc.value.tr,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textColor
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              controller.onSelectCancel();
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
                                  controller.titleButton1.value.tr,
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
                              controller.onSelectConfirm();
                            },
                            child: Container(
                              height: 50,
                              padding: EdgeInsets.only(left: 20, right: 20),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: AppColors.backgroundItemColor,
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                      color: AppColors.textColor,
                                      width: 1
                                  )
                              ),
                              child: Center(
                                child: Text(
                                  controller.titleButton2.value.tr,
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
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}