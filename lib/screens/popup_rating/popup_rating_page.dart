import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'popup_rating_controller.dart';

class PopupRatingPage extends GetView<PopupRatingController> {
  const PopupRatingPage({Key? key}) : super(key: key);

  @override
  PopupRatingController get controller =>
      Get.isRegistered<PopupRatingController>()
          ? Get.find<PopupRatingController>()
          : Get.put(PopupRatingController());

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 28),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Obx(
            () => AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: controller.isRatedThankYou.value
                  ? _buildThankYouContent()
                  : _buildRatingContent(),
            ),
          ),
        ),
      ),
    );
  }

  /// Giao diện popup mời Rating ban đầu (Image 1)
  Widget _buildRatingContent() {
    return Column(
      key: const ValueKey('rating_content'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Nút Close "X" ở góc trên bên trái
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 14, top: 14),
            child: GestureDetector(
              onTap: () => controller.onSelectClose(),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.all(6),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ),

        // Icon Thumbs-up hình tròn nền trắng
        Container(
          width: 68,
          height: 68,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.thumb_up_alt_rounded,
              color: Color(0xFF3B82F6),
              size: 34,
            ),
          ),
        ),

        const SizedBox(height: 18),

        // Tiêu đề: "Bạn có thích [App Name]?"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Do you like All Video Downloader: HD Saver?".tr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Mô tả: "Chúng tôi cần phản hồi và động lực của bạn để mang đến cho bạn trải nghiệm tốt hơn."
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            "We need your feedback and motivation to provide you with a better experience.".tr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFB0B0B0),
              fontSize: 13.5,
              fontWeight: FontWeight.normal,
              height: 1.4,
              decoration: TextDecoration.none,
            ),
          ),
        ),

        const SizedBox(height: 22),

        // 5 ngôi sao viền vàng (outline)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final star = index + 1;
            return GestureDetector(
              onTap: () => controller.onSelectStar(star),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: const Icon(
                  Icons.star_outline_rounded,
                  color: Color(0xFFFFB800),
                  size: 38,
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 24),

        // Nút "Không, cám ơn." ("No, thanks")
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GestureDetector(
            onTap: () => controller.onSelectClose(),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  "No, thanks".tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  /// Giao diện "Cảm ơn!" khi chọn <= 3 sao (Image 2)
  Widget _buildThankYouContent() {
    return Column(
      key: const ValueKey('thank_you_content'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Nút Close "X" ở góc trên bên trái
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 14, top: 14),
            child: GestureDetector(
              onTap: () => controller.onSelectClose(),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.all(6),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Icon Checkmark tròn nền sáng
        Container(
          width: 68,
          height: 68,
          decoration: const BoxDecoration(
            color: Color(0xFFE8F1FD),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.check_rounded,
              color: Color(0xFF3B82F6),
              size: 38,
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Text: "Cảm ơn!"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Thank you!".tr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
            ),
          ),
        ),

        const SizedBox(height: 36),
      ],
    );
  }
}