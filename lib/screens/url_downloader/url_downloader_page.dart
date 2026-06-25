


import 'package:cscmobi_app/core/values/app_colors.dart';
import 'package:cscmobi_app/screens/url_downloader/url_downloader_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import '../../utils/Utils.dart';
import '../../core/utils/dialog_util.dart';

class URLDownloaderPage extends GetView<URLDownloaderController> {
  @override
  URLDownloaderController get controller => Get.isRegistered<URLDownloaderController>() ? Get.find<URLDownloaderController>() : Get.put(URLDownloaderController());

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              buildNavigation(),
              Expanded(
                child: buildContent(),
              )
            ],
          ),
        ),
      ),
    );
  }

  buildContent() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(controller.url.value)),

              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                domStorageEnabled: true,
                // Cực kỳ quan trọng: Dùng User-Agent của Chrome trên Android thực tế
                userAgent: "Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Mobile Safari/537.36",
                allowsInlineMediaPlayback: true,
                useShouldOverrideUrlLoading: true, // Để bắt link app fb://
                cacheEnabled: true,
                // Một số máy Android bị trắng trang nếu không bật cái này
                mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
              ),
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                var uri = navigationAction.request.url!;

                // Nếu link không phải web (fb://, intent://, ...)
                if (!["http", "https"].contains(uri.scheme)) {
                  return NavigationActionPolicy.CANCEL; // Chặn lỗi trên WebView
                }

                if (Utils.isYoutubeUrl(uri.toString())) {
                  DialogUtil.showYoutubeNotSupportedPopup();
                  return NavigationActionPolicy.CANCEL;
                }

                return NavigationActionPolicy.ALLOW;
              },
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  useOnLoadResource: true,  // Bật để nhận onLoadResource
                ),
              ),
              onTitleChanged: (webController, title) {
                this.controller.webViewController = webController;
                controller.title.value = title ?? '';
              },
              onLoadStop: (webController, url) async {
                this.controller.webViewController = webController;
              },
              onLoadResource: (controller, resource) {
                // Khi có resource được load, kiểm tra và thêm video nếu hợp lệ
                String url = resource.url.toString();
                // Facebook thường dùng các domain như .fbcdn.net và chứa các pattern video
                // TikTok dùng các domain như .tiktokv.com hoặc .akamaized.net
                if (url.contains(".mp4") ||
                    url.contains("video_mp4") ||
                    url.contains("/video/") ||
                    url.contains(".m4v") ||
                    url.contains("blob:")) {
                  print("Phát hiện URL nghi vấn video: $url");
                  // Tại đây bạn có thể lưu URL này lại để xử lý
                }
                print("Loaded resource: ${resource.url}");
                this.controller.addVideoIfValid(resource);
              },
              onProgressChanged: (controller, progress) {
                print("Progress load: $progress%");
                // Detect trang đang load thêm (progress không 100 ngay)
              },
            ),
          ),
          Positioned(
            bottom: 40,
            right: 20,
            child: GestureDetector(
              onTap: () {
                if (controller.videoList.length > 0) {
                  controller.showBottomDownloadView();
                } else {
                  return;
                }
              },
              child: Obx(() {
                return Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: controller.videoList.length > 0 ? AppColors.main : Color(0xFF6F7084)
                  ),
                  child: Center(
                    child: Image.asset(
                      "assets/png/icon_download.png",
                      width: 40,
                      height: 40,
                    ),
                  ),
                );
              }),
            ),
          )
        ],
      )
    );
  }

  buildNavigation() {
    return Container(
      height: 64,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              controller.onSelectBack();
            },
            child: Container(
              width: 40,
              height: 40,
              margin: EdgeInsets.only(left: 5),
              color: Colors.transparent,
              child: Icon(
                Icons.arrow_back,
                color: AppColors.textColor,
                size: 25,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.white,
                borderRadius: BorderRadius.circular(25)
              ),
              padding: EdgeInsets.only(left: 20, right: 20, bottom: 5),
              child: TextField(
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter URL here'.tr,
                  hintStyle: TextStyle(
                      color: AppColors.grayText,
                      fontSize: 14,
                      fontWeight: FontWeight.w400
                  ),
                ),
                focusNode: controller.focusNode,
                controller: controller.searchTextFieldController,
                onTap: () => controller.onStartSearch(),
                onChanged: (text) => controller.onTextSearchChange(text),
                onSubmitted: (text) => controller.onSubmitSearch(text),
                // onTapOutside: (event) => controller.onEndSearch(),
                style: TextStyle(
                    color: AppColors.blackText,
                    fontSize: 14,
                    fontWeight: FontWeight.w400
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              controller.onSubmitSearch(controller.searchTextFieldController.text);
            },
            child: Container(
              width: 40,
              height: 40,
              margin: EdgeInsets.only(left: 5),
              color: Colors.transparent,
              child: Center(
                child: Image.asset(
                  "assets/png/icon_search_white.png",
                  width: 20,
                  height: 20,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
