

import 'package:cscmobi_app/screens/url_downloader/url_downloader_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class URLDownloaderDetailPage extends GetView<URLDownloaderController> {
  @override
  URLDownloaderController get controller => Get.isRegistered<URLDownloaderController>() ? Get.find<URLDownloaderController>() : Get.put(URLDownloaderController());

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Text(
          "URL Downloader Detail Page"
        ),
      ),
    );
  }
}