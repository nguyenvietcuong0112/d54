import 'package:cscmobi_app/core/values/app_colors.dart';
import 'package:cscmobi_app/screens/popup_confirm_quit/popup_confirm_quit_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PopupConfirmQuitPage extends GetView<PopupConfirmQuitController> {
  const PopupConfirmQuitPage({super.key});

  @override
  PopupConfirmQuitController get controller =>
      Get.isRegistered<PopupConfirmQuitController>()
          ? Get.find<PopupConfirmQuitController>()
          : Get.put(PopupConfirmQuitController());

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.backgroundItemColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Close 'X' button at top right
            Positioned(
              top: 14,
              right: 14,
              child: GestureDetector(
                onTap: controller.onSelectCancel,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: AppColors.textColor.withValues(alpha: 0.6),
                    size: 18,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Luminous exit icon badge
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.main.withValues(alpha: 0.2),
                          AppColors.main.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: AppColors.main.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.main.withValues(alpha: 0.12),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.exit_to_app_rounded,
                        color: AppColors.main,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Title
                  Obx(
                    () => Text(
                      controller.title.value.tr,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textColor,
                        letterSpacing: 0.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Obx(
                      () => Text(
                        controller.desc.value.tr,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondaryColor,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  // Action buttons
                  Row(
                    children: [
                      // Secondary Button: Exit ("Yes")
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (controller.isEnableButton1.value) {
                              controller.onSelectConfirm();
                            }
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12),
                                width: 1,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Obx(
                              () => Text(
                                controller.titleButton1.value.tr +
                                    (!controller.isEnableButton1.value &&
                                            controller.countDownValue.value > 0
                                        ? " (${controller.countDownValue.value})"
                                        : ""),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: controller.isEnableButton1.value
                                      ? AppColors.textColor.withValues(alpha: 0.85)
                                      : AppColors.textColorGreyLight,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Primary Button: Stay ("No")
                      Expanded(
                        child: GestureDetector(
                          onTap: controller.onSelectCancel,
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.main,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.main.withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Obx(
                              () => Text(
                                controller.titleButton2.value.tr,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.blackText,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}