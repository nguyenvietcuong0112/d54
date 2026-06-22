

import 'dart:io';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'app_setting.dart';


class Utils {

  static String getTitleDayOnlyFromDay(DateTime date) {
    var today = DateTime.now();
    var yesterday = today.subtract(Duration(days: 1));
    var tomorrow = today.add(Duration(days: 1));
    var dateFormater = DateFormat("EEE dd MMM", AppSetting.selectedLanguageCode);
    if (date.day == today.day) {
      return "Today".tr;
    } else if (date.day == yesterday.day) {
      return "Yesterday".tr;
    } else if (date.day == tomorrow.day) {
      return "Tomorrow".tr;
    } else {
      return dateFormater.format(date);
    }
  }

  static bool isYoutubeUrl(String? url) {
    if (url == null || url.trim().isEmpty) {
      return false;
    }

    // Chuyển về lowercase để dễ so sánh
    final String lowerUrl = url.toLowerCase().trim();

    // Regex để match các domain YouTube phổ biến
    final RegExp youtubeRegex = RegExp(
      r'(?:'
      r'(?:https?:\/\/)?'                  // optional protocol
      r'(?:www\.|m\.|music\.|shorts\.)?'   // optional subdomain
      r'(?:'
      r'youtube\.com'                      // youtube.com
      r'|youtu\.be'                        // youtu.be
      r'|youtube-nocookie\.com'            // youtube-nocookie.com
      r'|youtube\.googleapis\.com'         // api (ít dùng nhưng có thể)
      r')'
      r'(?:\/|$|[?#])'                     // kết thúc domain hoặc có path/query
      r')',
      caseSensitive: false,
    );

    return youtubeRegex.hasMatch(lowerUrl);
  }

  static String getVideoQualityLabel(double? width, double? height) {
    // Nếu thiếu dữ liệu → trả về unknown
    if (width == null || height == null || width <= 0 || height <= 0) {
      return "720p";
    }

    // Lấy chiều cao làm yếu tố chính (quy ước chuẩn cho HD trở lên)
    final int h = height.round();

    // Một số quy ước phổ biến (theo YouTube, Netflix, Vimeo...)
    if (h >= 4320) {
      return "8K"; // ~4320p
    } else if (h >= 2160) {
      return "4K"; // 2160p
    } else if (h >= 1440) {
      return "1440p"; // 2K / QHD
    } else if (h >= 1080) {
      return "1080p"; // Full HD
    } else if (h >= 720) {
      return "720p"; // HD
    } else if (h >= 480) {
      return "480p"; // SD
    } else if (h >= 360) {
      return "360p"; // Low
    } else if (h >= 240) {
      return "240p"; // Very Low
    } else {
      return "Low";
    }
  }

  static Future<String?> getVideoExtension(File file) async {
    final ext = p.extension(file.path).toLowerCase();
    return ext;
  }

  static String getVideoExtension2(String fileUrl) {
    final ext = p.extension(fileUrl).toLowerCase();
    return ext;
  }

  String getCurrencySymbol(String currencyCode) {
    final format = NumberFormat.simpleCurrency(name: currencyCode);
    return format.currencySymbol;
  }
}