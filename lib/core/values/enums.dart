

import 'package:get/get.dart';

enum DownloadType {
  facebook,
  instagram,
  tiktok,
  twitter,
  pinterest,
  addUrl,
  webview
}

extension DownloadTypeExtension on DownloadType {
  String get getName {
    switch (this) {
      case DownloadType.facebook:
        return "Facebook".tr;
      case DownloadType.instagram:
        return "Instagram".tr;
      case DownloadType.tiktok:
        return "TikTok".tr;
      case DownloadType.twitter:
        return "Twitter".tr;
      case DownloadType.pinterest:
        return "Pinterest".tr;
      case DownloadType.addUrl:
        return "Add URL".tr;
      case DownloadType.webview:
        return "URL".tr;
    }
  }
}