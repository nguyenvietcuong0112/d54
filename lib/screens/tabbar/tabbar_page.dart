import 'package:cscmobi_app/core/values/app_colors.dart';
import 'package:cscmobi_app/screens/history_tab/history_tab_page.dart';
import 'package:cscmobi_app/screens/home_tab/home_tab_page.dart';
import 'package:cscmobi_app/screens/tabbar/tabbar_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Utils/app_setting.dart';
import '../../customwidget/wrap_keep_alive_tab.dart';
import '../../helper/admob_helper.dart';
import '../../helper/firebase_remote_config_service.dart';
import '../../customwidget/shimmer.dart';

class TabbarPage extends GetView<TabbarController> {
  @override
  TabbarController get controller => Get.isRegistered<TabbarController>()
      ? Get.find<TabbarController>()
      : Get.put(TabbarController());

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: GetBuilder<TabbarController>(
          builder: (_) {
            return Scaffold(
              backgroundColor: AppColors.redPrimary,
              resizeToAvoidBottomInset: false,
              extendBody: true,
              body: Container(
                width: double.infinity,
                height: double.infinity,
                child: PageView(
                  controller: controller.pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    WrapKeepAliveTab(child: HomeTabPage()),
                    WrapKeepAliveTab(child: HistoryTabPage()),
                  ],
                ),
              ),
              bottomNavigationBar: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: 72,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(
                          0xFF161625), // Nền tối Bottom Navigation đồng điệu màu nền chính
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1), // màu shadow
                          blurRadius: 4, // độ tán
                          offset:
                              const Offset(0, -2), // hướng shadow (lên trên)
                        ),
                      ],
                    ),
                    child: Obx(() {
                      final int currentIndex = controller.tabbarIndex.value;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Tab 1: Home
                          _buildTabItem(
                            index: 0,
                            currentIndex: currentIndex,
                            label: 'Home'.tr,
                            iconAsset: "assets/png/tab_home.png",
                            iconAssetSelected:
                                "assets/png/tab_home_selected.png",
                            onTap: () => controller.onChangeTabbarIndex(0),
                          ),
                          // Tab 2: Download (History)
                          _buildTabItem(
                            index: 1,
                            currentIndex: currentIndex,
                            label: 'Download'.tr,
                            iconAsset: "assets/png/tab_download.png",
                            iconAssetSelected:
                                "assets/png/tab_download_selected.png",
                            onTap: () => controller.onChangeTabbarIndex(1),
                          ),
                        ],
                      );
                    }),
                  ),
                  Obx(() {
                    final bool isPremium = AppSetting.isPremiumUser.value ||
                        AppSetting.isRemoveAds.value;
                    final bool isShowAd =
                        FirebaseRemoteConfigService.getBoolConfigByKey(
                            FirebaseRemoteConfigService.banner_home);
                    if (isPremium || !isShowAd || controller.isBannerAdLoadingFailed.value) {
                      return const SizedBox();
                    }

                    return Container(
                      height: 60,
                      width: double.infinity,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: (controller.isBannerAdLoaded.value &&
                                controller.bannerAd != null)
                            ? Container(
                                key: const ValueKey('banner_loaded'),
                                color: Colors.white,
                                child: AdmobAdHelper().getBottomBannerAdWidget(
                                    ad: controller.bannerAd!),
                              )
                            : Shimmer.fromColors(
                                key: const ValueKey('banner_loading'),
                                baseColor: const Color(0xFF2C2C3E),
                                highlightColor: const Color(0xFF3D3D5C),
                                child: Container(
                                  color: const Color(0xFF2C2C3E),
                                  width: double.infinity,
                                  height: 60,
                                ),
                              ),
                      ),
                    );
                  })
                ],
              ),
            );
          },
        ),
        onWillPop: () => controller.showBackDialog(context));
  }

  // Widget hỗ trợ xây dựng tab item chuẩn thiết kế mới (có viên thuốc nền active)
  Widget _buildTabItem({
    required int index,
    required int currentIndex,
    required String label,
    required String iconAsset,
    required String iconAssetSelected,
    required VoidCallback onTap,
  }) {
    final bool isActive = (currentIndex == index);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Phần bọc biểu tượng (có hình viên thuốc khi active)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.main
                  : Colors.transparent, // Nền màu vàng chanh khi active
              borderRadius: BorderRadius.circular(16),
            ),
            child: Image.asset(
              isActive ? iconAssetSelected : iconAsset,
              width: 24,
              height: 24,
              color: isActive
                  ? AppColors.black
                  : const Color(
                      0xFF6F7084), // Icon màu đen khi active, xám mờ khi inactive
            ),
          ),
          const SizedBox(height: 4),
          // Chữ hiển thị phía dưới
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive
                  ? AppColors.main
                  : const Color(
                      0xFF6F7084), // Chữ màu vàng chanh khi active, xám mờ khi inactive
            ),
          ),
        ],
      ),
    );
  }
}
