import 'dart:convert';
import 'dart:typed_data';
import 'package:cscmobi_app/core/base/base_controller.dart';
import 'package:cscmobi_app/api_rest/api_repository.dart';
import 'package:cscmobi_app/models/download_model.dart';
import 'package:cscmobi_app/models/response_model.dart';
import 'package:cscmobi_app/models/format_model.dart';
import 'package:cscmobi_app/helper/media_store_helper.dart';
import 'package:cscmobi_app/core/utils/app_util.dart';
import 'package:cscmobi_app/core/utils/dialog_util.dart';
import 'package:cscmobi_app/core/values/app_colors.dart';
import 'package:cscmobi_app/helper/firebase_remote_config_service.dart';
import 'package:cscmobi_app/screens/history_tab/history_tab_controller.dart';
import 'package:cscmobi_app/screens/tabbar/tabbar_controller.dart';
import 'package:cscmobi_app/helper/video_download_helper.dart';
import 'package:cscmobi_app/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../helper/firebase_helper.dart';
import '../../core/values/enums.dart';
import '../popup_rename/popup_rename_controller.dart';
import '../popup_rename/popup_rename_page.dart';

class URLDownloaderController extends BaseController {
  static const String _keyLastSearchedUrl = "last_entered_searched_url";

  InAppWebViewController? webViewController;
  final List<String> videoExtensions = [
    '.mp4', '.mkv', '.webm', '.mov', '.avi', '.wmv', '.flv', '.f4v',
    '.mpg', '.mpeg', '.m4v', '.3gp', '.3g2', '.ogv', '.ts', '.m2ts', '.m3u8'
  ];
  RxList<Map<String, dynamic>> videoList = RxList();
  TextEditingController searchTextFieldController = TextEditingController();
  RxBool isSearching = false.obs;
  RxBool hasSearchText = false.obs;
  var url = "".obs;
  RxSet<int> selectedIndices = <int>{0}.obs;
  var title = ''.obs;
  final FocusNode focusNode = FocusNode();
  DownloadType downloadType = DownloadType.webview;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    FirebaseHelper.setTrackingScreenName("URLDownloaderScreen");
    downloadType = Get.arguments != null ? (Get.arguments["type"] ?? DownloadType.webview) : DownloadType.webview;
    String initialUrl = Get.arguments != null ? (Get.arguments["url"] ?? "") : "";
    if (initialUrl.isEmpty) {
      try {
        if (Get.isRegistered<SharedPreferences>()) {
          final prefs = Get.find<SharedPreferences>();
          initialUrl = prefs.getString(_keyLastSearchedUrl) ?? "";
        }
      } catch (_) {}
    }
    if (initialUrl.isNotEmpty) {
      initialUrl = initialUrl.trim();
      if (Utils.isYoutubeUrl(initialUrl)) {
        Future.delayed(Duration.zero, () {
          DialogUtil.showYoutubeNotSupportedPopup();
        });
        initialUrl = "";
      } else {
        final bool isUrl = initialUrl.contains('.') && !initialUrl.contains(' ');
        if (isUrl) {
          if (!initialUrl.startsWith(RegExp(r'https?://', caseSensitive: false))) {
            initialUrl = 'https://$initialUrl';
          }
        } else {
          initialUrl = 'https://www.google.com/search?q=${Uri.encodeComponent(initialUrl)}';
        }
      }
    }
    url.value = initialUrl;
    searchTextFieldController.text = url.value;
    hasSearchText.value = searchTextFieldController.text.isNotEmpty;
    searchTextFieldController.addListener(() {
      hasSearchText.value = searchTextFieldController.text.isNotEmpty;
    });
    if (url.value.isNotEmpty) {
    } else {
      focusNode.requestFocus();
    }
  }

  void saveLastSearchedUrl(String text) {
    String trimmed = text.trim();
    if (trimmed.isEmpty || trimmed.contains("about:blank")) return;
    try {
      if (Get.isRegistered<SharedPreferences>()) {
        final prefs = Get.find<SharedPreferences>();
        prefs.setString(_keyLastSearchedUrl, trimmed);
      }
    } catch (_) {}
  }

  void clearLastSearchedUrl() {
    try {
      if (Get.isRegistered<SharedPreferences>()) {
        final prefs = Get.find<SharedPreferences>();
        prefs.remove(_keyLastSearchedUrl);
      }
    } catch (_) {}
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    focusNode.dispose();
    searchTextFieldController.dispose();
    super.onClose();
  }

  bool isVideoUrl(String url) {
    try {
      String lower = url.toLowerCase();
      String path = Uri.parse(url).path.toLowerCase();
      if (videoExtensions.any((ext) => path.endsWith(ext))) {
        return true;
      }
      if (lower.contains("video_mp4") || 
          lower.contains(".mp4?") || 
          lower.contains(".m3u8?") ||
          lower.contains("/video/")) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void addVideoIfValid(LoadedResource resource) async {
    String url = resource.url.toString();
    // Tránh trùng
    if (videoList.any((v) => v['url'] == url)) return;
    if (Utils.isYoutubeUrl(url)) return;
    bool isVideo = isVideoUrl(url);

    if (isVideo) {
      var thumb = await generateThumbnail(url);
      videoList.add({
        'title': title.value,
        'url': url,
        'thumbnail': thumb,
      });
      print("Đã thêm video: $url");
      fetchVideoSize(url);
    }
  }

  void fetchVideoSize(String url) async {
    try {
      // 1. Thử giải mã tham số 'efg' trong URL (chứa duration_s và bitrate mã hóa base64 của Facebook)
      try {
        final uriParsed = Uri.parse(url);
        final efgParam = uriParsed.queryParameters["efg"];
        if (efgParam != null && efgParam.isNotEmpty) {
          final decodedUrl = Uri.decodeComponent(efgParam);
          final jsonBytes = base64.decode(base64.normalize(decodedUrl));
          final jsonStr = utf8.decode(jsonBytes);
          final mapData = json.decode(jsonStr);
          if (mapData is Map && mapData.containsKey("duration_s") && mapData.containsKey("bitrate")) {
            final durationS = double.tryParse(mapData["duration_s"].toString()) ?? 0;
            final bitrate = double.tryParse(mapData["bitrate"].toString()) ?? 0;
            if (durationS > 0 && bitrate > 0) {
              final estimatedBytes = ((durationS * bitrate) / 8).toInt();
              if (estimatedBytes > 0) {
                final sizeStr = MediaStoreHelper.convertFileSizeToString(estimatedBytes);
                final idx = videoList.indexWhere((v) => v['url'] == url);
                if (idx != -1) {
                  videoList[idx]['size'] = sizeStr;
                  videoList.refresh();
                }
                return;
              }
            }
          }
        }
      } catch (_) {}

      // 2. Thử xóa bytestart/byteend và gửi HTTP HEAD
      String cleanUrlStr = url;
      try {
        final uriParsed = Uri.parse(url);
        if (uriParsed.queryParameters.containsKey("bytestart") ||
            uriParsed.queryParameters.containsKey("byteend") ||
            uriParsed.queryParameters.containsKey("range")) {
          final newQueryParameters = Map<String, String>.from(uriParsed.queryParameters);
          newQueryParameters.remove("bytestart");
          newQueryParameters.remove("byteend");
          newQueryParameters.remove("range");
          cleanUrlStr = uriParsed.replace(queryParameters: newQueryParameters).toString();
        }
      } catch (_) {}

      final headers = {
        "User-Agent": "Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Mobile Safari/537.36",
      };
      if (url.contains("facebook.com") || url.contains(".fbcdn.net")) {
        headers["Referer"] = "https://www.facebook.com/";
      } else if (url.contains("instagram.com")) {
        headers["Referer"] = "https://www.instagram.com/";
      }

      var response = await http.head(Uri.parse(cleanUrlStr), headers: headers).timeout(const Duration(seconds: 2));
      if (response.statusCode == 403 || response.statusCode == 400 || response.statusCode == 404) {
        response = await http.head(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 2));
      }
      if (response.statusCode != 200 && response.statusCode != 201 && response.statusCode != 206) {
        headers["Range"] = "bytes=0-0";
        response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 2));
      }

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 206) {
        String? contentLengthStr = response.headers['content-length'];
        final contentRange = response.headers['content-range'];
        final contentType = response.headers['content-type'] ?? '';

        if (contentRange != null && contentRange.contains('/')) {
          contentLengthStr = contentRange.split('/').last;
        }

        if (contentLengthStr != null) {
          final sizeInBytes = int.tryParse(contentLengthStr);
          if (sizeInBytes != null) {
            final sizeStr = MediaStoreHelper.convertFileSizeToString(sizeInBytes);
            final idx = videoList.indexWhere((v) => v['url'] == url);
            if (idx != -1) {
              videoList[idx]['size'] = sizeStr;
              videoList[idx]['contentType'] = contentType;
              videoList.refresh();
            }
          }
        }
      }
    } catch (e) {
      print("Lỗi khi fetch video size cho URL $url: $e");
    }
  }

  String getUrlDisplayDetails(String url) {
    try {
      final uri = Uri.parse(url);
      final host = uri.host;
      String typeLabel = "Video Stream".tr;
      
      String lowerUrl = url.toLowerCase();
      if (lowerUrl.contains(".m3u8")) {
        typeLabel = "HLS Stream (.m3u8)".tr;
      } else if (lowerUrl.contains(".m4s") || 
                 lowerUrl.contains("bytestart") || 
                 lowerUrl.contains("byteend") || 
                 lowerUrl.contains("chunk") || 
                 lowerUrl.contains("fragment")) {
        typeLabel = "DASH Chunk (Fragment)".tr;
      } else if (lowerUrl.contains("audio") || lowerUrl.contains("acodec") || lowerUrl.contains(".mp3") || lowerUrl.contains(".m4a")) {
        typeLabel = "Audio Stream".tr;
      } else if (lowerUrl.contains("preview")) {
        typeLabel = "Preview Video / Thumbnail".tr;
      } else if (lowerUrl.contains(".mp4")) {
        typeLabel = "MP4 Stream".tr;
      }

      String resLabel = "";
      final regExp = RegExp(r'(\d+x\d+)|_(\d+p)_');
      final match = regExp.firstMatch(url);
      if (match != null) {
        resLabel = " | ${match.group(0)!.replaceAll('_', '')}";
      }

      return "$typeLabel$resLabel ($host)";
    } catch (e) {
      return "Video Stream".tr;
    }
  }

  Future<Uint8List?> generateThumbnail(String videoUrl) async {
    try {
      final uint8list = await VideoThumbnail.thumbnailData(
        video: videoUrl,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 300,
        quality: 75,
      );
      return uint8list;
    } catch (e) {
      print("Lỗi generate thumbnail: $e");
      return null;
    }
  }

  onSelectEditName(int index) async {
    Get.back();
    var result = await Get.dialog(GetBuilder<PopupRenameController>(
      init: PopupRenameController(), // Optional: Initialize controller here if needed
      builder: (controller) {
        return PopupRenamePage();
      },
    ),
        useSafeArea: true,
        arguments: {
          "name": videoList[index]['title'] ?? '',
        }
    );
    if (result != null && result['newName'] != null) {
      videoList[index]['title'] = result['newName'];
      videoList.refresh();
    }
    showBottomDownloadView();
  }

  onSelectDownload() async {
    if (searchTextFieldController.text.isEmpty) {
      AppUtil.showNormalToast("Please enter URL".tr);
      return;
    }
    if (selectedIndices.isEmpty) {
      AppUtil.showNormalToast("Please select at least one video".tr);
      return;
    }

    String? pageUrl;
    Map<String, String> headers = {
      "User-Agent": "Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Mobile Safari/537.36",
    };

    try {
      if (webViewController != null) {
        var currentUri = await webViewController!.getUrl();
        pageUrl = currentUri?.toString();
        if (currentUri != null) {
          headers["Referer"] = currentUri.toString();
        }
      }
    } catch (e) {
      print("Error getting cookies/headers for download: $e");
    }

    bool useBackendParser = false;
    DownloadType dType = downloadType;

    if (pageUrl != null && pageUrl.isNotEmpty) {
      String lowerPageUrl = pageUrl.toLowerCase();
      if (lowerPageUrl.contains("facebook.com") || lowerPageUrl.contains("fb.watch") || lowerPageUrl.contains("fb.gg")) {
        useBackendParser = true;
        dType = DownloadType.facebook;
      } else if (lowerPageUrl.contains("instagram.com")) {
        useBackendParser = true;
        dType = DownloadType.instagram;
      } else if (lowerPageUrl.contains("tiktok.com")) {
        useBackendParser = true;
        dType = DownloadType.tiktok;
      }
    }

    // Dismiss bottom sheet and search screen
    Get.back();
    Get.back();

    if (Get.isRegistered<TabbarController>()) {
      var tabbarController = Get.isRegistered<TabbarController>() ? Get.find<TabbarController>() : Get.put(TabbarController());
      tabbarController.onChangeTabbarIndex(1);
    }
    if (Get.isRegistered<HistoryTabController>()) {
      var historyController = Get.isRegistered<HistoryTabController>() ? Get.find<HistoryTabController>() : Get.put(HistoryTabController());
      historyController.tabController.animateTo(0);
    }

    String initialTitle = "${dType.getName}_Video_${DateTime.now().millisecondsSinceEpoch}";
    if (selectedIndices.isNotEmpty && selectedIndices.first < videoList.length) {
      var selected = videoList[selectedIndices.first];
      if (selected['title'] != null && (selected['title'] as String).trim().isNotEmpty) {
        initialTitle = selected['title'].trim();
      }
    }

    List<DownloadItem> pendingItems = [];

    if (useBackendParser && pageUrl != null) {
      if (selectedIndices.isNotEmpty) {
        for (var index in selectedIndices) {
          if (index < videoList.length) {
            var itemTitle = videoList[index]['title'] != null ? videoList[index]['title'].toString().trim() : initialTitle;
            if (itemTitle.isEmpty) itemTitle = initialTitle;
            pendingItems.add(VideoDownloadHelper.instance.addPendingItem(title: itemTitle, type: dType));
          }
        }
      }
      if (pendingItems.isEmpty) {
        pendingItems.add(VideoDownloadHelper.instance.addPendingItem(title: initialTitle, type: dType));
      }

      try {
        ResponseModel resultUrl;
        if (dType == DownloadType.tiktok) {
          resultUrl = await ApiRepository().sendPostRequestDownloadTiktok(pageUrl);
        } else {
          resultUrl = await ApiRepository().sendPostRequestDownloadUrl(pageUrl);
        }

        if (resultUrl.code == 200 || resultUrl.code == 201) {
          var downloadModel = DownloadModel.fromJson(resultUrl.data);
          double currentDuration = downloadModel.duration;
          
          if (downloadModel.formats.isNotEmpty) {
            var formats = downloadModel.formats;
            FormatModel bestFormat = formats.first;
            
            // 1. Tìm định dạng có cả video và audio (Combined format)
            bool foundCombined = false;
            for (var format in formats) {
              bool isVideo = format.vcodec != "none" && format.vcodec.isNotEmpty;
              bool hasAudio = format.acodec != "none" && format.acodec.isNotEmpty;
              if (isVideo && hasAudio) {
                bestFormat = format;
                foundCombined = true;
                break;
              }
            }

            // 2. Nếu không có định dạng Combined, tìm định dạng Video Only tốt nhất (độ phân giải lớn nhất)
            if (!foundCombined) {
              FormatModel? bestVideo;
              for (var format in formats) {
                bool isVideo = format.vcodec != "none" && format.vcodec.isNotEmpty;
                if (isVideo) {
                  if (bestVideo == null || (format.width * format.height) > (bestVideo.width * bestVideo.height)) {
                    bestVideo = format;
                  }
                }
              }
              if (bestVideo != null) {
                bestFormat = bestVideo;
              }
            }

            String? audioUrl;
            bool isVideoOnly = bestFormat.acodec == "none" || bestFormat.acodec.isEmpty;
            if (isVideoOnly) {
              FormatModel? bestAudio;
              for (var f in formats) {
                if ((f.vcodec == "none" || f.vcodec.isEmpty) && f.acodec != "none" && f.acodec.isNotEmpty) {
                  if (bestAudio == null || f.fileSize > bestAudio.fileSize) {
                    bestAudio = f;
                  }
                }
              }
              if (bestAudio != null) {
                audioUrl = bestAudio.url;
              }
            }

            var newName = bestFormat.title.trim();
            if (newName.isEmpty) {
              newName = initialTitle;
            }
            if (newName.length > 100) {
              newName = newName.substring(0, 100);
            }

            for (var item in pendingItems) {
              VideoDownloadHelper.instance.removePendingItem(item);
            }
            pendingItems.clear();

            if (Get.isRegistered<TabbarController>()) {
              var tabbarController = Get.isRegistered<TabbarController>() ? Get.find<TabbarController>() : Get.put(TabbarController());
              tabbarController.onChangeTabbarIndex(1);
              if (Get.isRegistered<HistoryTabController>()) {
                var controller = Get.isRegistered<HistoryTabController>() ? Get.find<HistoryTabController>() : Get.put(HistoryTabController());
                controller.onStartDownload(
                  bestFormat.url,
                  newName,
                  dType,
                  audioUrl: audioUrl,
                  duration: currentDuration,
                  size: bestFormat.fileSize > 0 ? MediaStoreHelper.convertFileSizeToString(bestFormat.fileSize.toInt()) : null,
                  headers: headers,
                );

                // Tải thêm các video khác nếu user chọn nhiều hơn 1 item trong list
                if (selectedIndices.length > 1) {
                  for (int i = 1; i < selectedIndices.length; i++) {
                    var idx = selectedIndices.elementAt(i);
                    if (idx < videoList.length) {
                      var v = videoList[idx];
                      var vUrl = v['url'];
                      var vName = v['title'] ?? '';
                      if (vUrl != null) {
                        controller.onStartDownload(vUrl, vName, dType, headers: headers);
                      }
                    }
                  }
                }
              }
            }
            return;
          }
        }
      } catch (e) {
        print("Error parsing page url in WebView download: $e");
      }

      for (var item in pendingItems) {
        VideoDownloadHelper.instance.removePendingItem(item);
      }
      pendingItems.clear();
    }

    // Fallback if not FB/Insta/TikTok or if API parsing failed
    if (Get.isRegistered<TabbarController>()) {
      var tabbarController = Get.isRegistered<TabbarController>() ? Get.find<TabbarController>() : Get.put(TabbarController());
      tabbarController.onChangeTabbarIndex(1);
      if (Get.isRegistered<HistoryTabController>()) {
        var controller = Get.isRegistered<HistoryTabController>() ? Get.find<HistoryTabController>() : Get.put(HistoryTabController());
        for (var index in selectedIndices) {
          if (index < videoList.length) {
            var video = videoList[index];
            var url = video['url'];
            var name = video['title'] ?? '';
            var newName = name;
            if (newName.length > 200) {
              newName = newName.substring(0, 200);
            }
            controller.onStartDownload(url, newName, dType, headers: headers);
          }
        }
      }
    }
  }

  onSelectClosePopup() {
    Get.back();
  }

  onStartSearch() {
    isSearching.value = true;
  }

  onTextSearchChange(String text) {
    url.value = text;
    hasSearchText.value = text.isNotEmpty;
    update();
  }

  onClearSearchText() {
    searchTextFieldController.clear();
    url.value = "";
    hasSearchText.value = false;
    clearLastSearchedUrl();
    focusNode.requestFocus();
    update();
  }

  onEndSearch() {
    isSearching.value = false;
    if (url.value.isNotEmpty && !url.value.contains("about:blank")) {
      searchTextFieldController.text = url.value;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    update();
  }

  onSubmitSearch(String text) {
    String trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    if (Utils.isYoutubeUrl(trimmedText)) {
      DialogUtil.showYoutubeNotSupportedPopup();
      return;
    }

    if (webViewController == null) {
      AppUtil.showNormalToast("Something went wrong while starting the download.".tr);
      return;
    }

    String finalUrl = trimmedText;
    
    // Check if it's a URL or search query
    final bool isUrl = trimmedText.contains('.') && !trimmedText.contains(' ');
    if (isUrl) {
      if (!trimmedText.startsWith(RegExp(r'https?://', caseSensitive: false))) {
        finalUrl = 'https://$trimmedText';
      }
    } else {
      // It's a search query, search on Google
      finalUrl = 'https://www.google.com/search?q=${Uri.encodeComponent(trimmedText)}';
    }

    url.value = finalUrl;
    searchTextFieldController.text = finalUrl;
    saveLastSearchedUrl(finalUrl);

    webViewController!.loadUrl(urlRequest: URLRequest(
      url: WebUri(finalUrl)
    ));
    FocusManager.instance.primaryFocus?.unfocus();
  }

  onSelectBack() {
    Get.back();
  }

  showBottomDownloadView() {
    Get.bottomSheet(
      Container(
        child: Container(
          width: double.infinity,
          height: 600,
          decoration: BoxDecoration(
              color: AppColors.backgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16)
            )
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Obx(() {
                  return ListView.builder(
                    itemCount: videoList.length,
                    padding: EdgeInsets.only(bottom: 100),
                    itemBuilder: (context, index) {
                      final video = videoList[index];
                      print("aaaaaaaaaasizeeeeee:${video['size']}");
                      print("aaaaaaaaaasizeeeeeeaaaaa:${video["url"]}");
                      debugPrint("aaaaaaa123123123ádasdas123:${video['url']}");

                      return GestureDetector(
                        onTap: () {
                          if (selectedIndices.contains(index)) {
                            selectedIndices.remove(index);
                          } else {
                            selectedIndices.add(index);
                          }
                        },
                        child: Container(
                          height: 100,
                          width: double.infinity,
                          padding: EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                              color: Colors.transparent
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Obx(() => selectedIndices.contains(index)
                                  ? Container(
                                width: 30,
                                height: 30,
                                child: Center(
                                  child: Icon(
                                    Icons.check_box_rounded,
                                    size: 24,
                                    color: AppColors.main,
                                  ),
                                ),
                              )
                                  : Container(
                                width: 30,
                                height: 30,
                                child: Center(
                                  child: Icon(
                                    Icons.check_box_outline_blank_outlined,
                                    size: 24,
                                    color: AppColors.gray,
                                  ),
                                ),
                              )),
                              const SizedBox(
                                width: 10,
                              ),
                              video['thumbnail'] != null
                                  ? Container(
                                width: 120,
                                height: 80,
                                decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                        image: MemoryImage(video['thumbnail']),
                                        fit: BoxFit.cover
                                    )
                                  ),
                                )
                                  : Container(
                                width: 120,
                                height: 80,
                                decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(8)
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.videocam,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.only(top: 8, bottom: 8),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        video['title'] ?? '',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textColor
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        getUrlDisplayDetails(video['url'] ?? ''),
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.lightGreyColor
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (video['size'] != null) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          "Size: ${video['size']}",
                                          style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.main
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              GestureDetector(
                                onTap: () => onSelectEditName(index),
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  child: Center(
                                    child: Image.asset(
                                      "assets/png/icon_edit_white.png",
                                      width: 24,
                                      height: 24,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 90,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xFF161625)
                  ),
                  child: Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () => onSelectClosePopup(),
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.transparent
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/png/icon_close2.png",
                                  width: 40,
                                  height: 40,
                                ),
                                Text(
                                  "Close".tr,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.textColor
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () => onSelectDownload(),
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.transparent
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/png/icon_download2.png",
                                  width: 40,
                                  height: 40,
                                ),
                                Text(
                                  "Download".tr,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.textColor
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      )
    );
  }
}