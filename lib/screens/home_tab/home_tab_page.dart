import 'package:cscmobi_app/ads/dimens/ad_dimen.dart';
import 'package:cscmobi_app/core/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Utils/app_setting.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/const/ad_id_extension.dart';
import '../../helper/firebase_remote_config_service.dart';
import '../../customwidget/shimmer.dart';
import '../setting_tab/setting_tab_page.dart';
import 'home_tab_controller.dart';

class HomeTabPage extends GetView<HomeTabController> {
  @override
  HomeTabController get controller => Get.isRegistered<HomeTabController>()
      ? Get.find<HomeTabController>()
      : Get.put(HomeTabController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    buildHeader(),
                    Flexible(
                      flex: 1,
                      child: buildContent(context),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 1. Phần Header: Căn giữa tiêu đề và phụ đề, tích hợp nút Setting góc trên bên phải
  Widget buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => Get.to(() => SettingTabPage()),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF2C2C3E), // Bo tròn xám tối sang trọng
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "HD Video Downloader & Player",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Download HD videos from all platforms without watermarks, and easily save feeds, posts, stories, MP3 audio, and photo slideshows as videos - fast and free."
                .tr,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF8E8E93),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            buildSearchURL(),
            const SizedBox(
              height: 10,
            ),
            if (FirebaseRemoteConfigService.getBoolConfigByKey(
                FirebaseRemoteConfigService.native_home))
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: EasyNativeAd(
                  factoryId: 'nativeNoMedia',
                  adId: MyAdIdName.nativeHomeAd.getId,
                  height: AdDimen.horizontalAdHeight,
                ),
              ),
            const SizedBox(
              height: 10,
            ),
            buildItem()
          ],
        ),
      ),
    );
  }

  // 2. Phần lưới Social Media: Định dạng lại lưới 3 cột x 2 hàng cực kỳ cân đối
  buildItem() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Social Media".tr,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
          ),
          SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.95,
            children: [
              _buildSocialCard(
                label: "Facebook",
                iconWidget: Image.asset("assets/png/item_facebook.png",
                    width: 44, height: 44),
                onTap: () => controller.onSelectFacebook(),
              ),
              // _buildSocialCard(
              //   label: "Youtube",
              //   iconWidget: Image.asset("assets/png/item_youtube.png",
              //       width: 44, height: 44),
              //   onTap: () => controller.onSelectURLDownloader(
              //       validUrl: "https://www.youtube.com"),
              // ),
              _buildSocialCard(
                label: "Pinterest",
                iconWidget: Image.asset("assets/png/item_pinterest.png",
                    width: 44, height: 44),
                onTap: () => controller.onSelectPinterest(),
              ),
              _buildSocialCard(
                label: "Instagram",
                iconWidget: Image.asset("assets/png/item_instagram.png",
                    width: 44, height: 44),
                onTap: () => controller.onSelectInstagram(),
              ),
              _buildSocialCard(
                label: "Twitter",
                iconWidget: Image.asset("assets/png/item_twitter.png",
                    width: 44, height: 44),
                onTap: () => controller.onSelectTwitter(),
              ),
              _buildSocialCard(
                label: "Tiktok",
                iconWidget: Image.asset("assets/png/item_tiktok.png",
                    width: 44, height: 44),
                onTap: () => controller.onSelectTiktok(),
              ),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSocialCard(
      {required String label,
      required Widget iconWidget,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(
              0xFF2C2C3E), // Nền thẻ xám tối sang trọng giống mockup
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(height: 8),
            Text(
              label.tr,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 3. Phần nhập Paste URL: Thẻ xám chứa thanh URL mô phỏng + Nút Download vàng chanh
  buildSearchURL() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C3E), // Nền xám tối
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => controller.onSelectURLDownloader(),
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF161625), // Ô nhập tối sâu
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Paste URL here".tr,
                    style: const TextStyle(
                      color: Color(0xFF6F7084),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const Icon(
                    Icons.assignment_turned_in_outlined, // Biểu tượng clipboard
                    color: Color(0xFF6F7084),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => controller.onSelectURLDownloader(),
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.main, // Vàng chanh nguyên bản
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  "Download".tr,
                  style: const TextStyle(
                    color: AppColors.black, // Chữ đen tương phản cao
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
