import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:cscmobi_app/Utils/app_setting.dart';
import 'package:cscmobi_app/core/utils/app_util.dart';
import 'package:cscmobi_app/core/values/enums.dart';
import 'package:cscmobi_app/helper/media_store_helper.dart';
import 'package:cscmobi_app/models/realm/download_realm_model.dart';
import 'package:cscmobi_app/screens/download_detail/download_detail_controller.dart';
import 'package:cscmobi_app/screens/history_tab/history_tab_controller.dart';
import 'package:ffmpeg_kit_flutter_new_https/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_https/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new_https/return_code.dart';
import 'package:ffmpeg_kit_flutter_new_https/stream_information.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:gal/gal.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:realm/realm.dart';

class DownloadItem {
  final String taskId;
  final String videoUrl;
  final String? fileName;
  String title;
  DownloadType type = DownloadType.addUrl;
  final RxDouble progress = 0.0.obs;                  // RxDouble
  final Rx<DownloadTaskStatus> status = DownloadTaskStatus.undefined.obs; // RxEnum
  double totalDurationMs = 0;
  String? audioUrl;
  final String? size;
  final Map<String, String>? headers;

  DownloadItem(
    this.taskId,
    this.videoUrl,
    this.fileName,
    this.title,
    this.type, {
    this.audioUrl,
    double? duration,
    this.size,
    this.headers,
  }) {
    if (duration != null) {
      totalDurationMs = duration * 1000.0;
    }
  }
}

@pragma('vm:entry-point')
class VideoDownloadHelper {

  // Singleton pattern (dễ dùng nhất khi không inject)
  static final VideoDownloadHelper instance = VideoDownloadHelper._internal();
  VideoDownloadHelper._internal();
  // Danh sách đang download
  final RxList<DownloadItem> activeDownloads = <DownloadItem>[].obs;
  // Map để tra cứu nhanh
  final Map<String, DownloadItem> _taskMap = {};
  // Callback khi có thay đổi progress/status (dùng để update UI)
  Function(DownloadItem item)? onProgressChanged;
  // Callback khi hoàn thành 1 task
  Function(DownloadItem item)? onCompleted;
  // Callback khi lỗi
  Function(DownloadItem item, String error)? onError;
  static const String _portName = 'video_downloader_port';
  static ReceivePort? _port;
  static Future<void>? _initFuture;

  bool _isInitialized = false;

  DateTime? _lastUiUpdateTime;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _initFuture ??= _initializeInternal();
    return _initFuture;
  }

  Future<void> _initializeInternal() async {
    try {
      await FlutterDownloader.initialize(debug: true);

      // Đóng port cũ nếu có để tránh rò rỉ hoặc lỗi Bad State
      if (_port != null) {
        try {
          _port!.close();
        } catch (_) {}
      }
      _port = ReceivePort();

      // Đăng ký port để nhận thông báo từ background
      IsolateNameServer.removePortNameMapping(_portName);
      final registered = IsolateNameServer.registerPortWithName(_port!.sendPort, _portName);
      print("VideoDownloadHelper IsolatePort registered: $registered");

      _port!.listen((message) async {
        print("hix hix download callback message: $message");
        final id = message[0] as String;
        final statusIndex = message[1] as int;
        final progressValue = message[2] as int;

        final item = _taskMap[id];
        if (item == null) {
          print("download callback item null for task id: $id. Task keys: ${_taskMap.keys.toList()}");
          return;
        }

        item.status.value = DownloadTaskStatus.values[statusIndex];
        item.progress.value = progressValue / 100.0;

        final now = DateTime.now();
        final shouldUpdate = _lastUiUpdateTime == null ||
            now.difference(_lastUiUpdateTime!).inMilliseconds >= 400; // 400ms ~ 2-3 lần/giây, đủ mượt

        if (shouldUpdate) {
          _lastUiUpdateTime = now;
          onProgressChanged?.call(item);
        }

        // Xử lý complete/failed NGAY LẬP TỨC (không throttle)
        if (item.status.value == DownloadTaskStatus.complete) {
          bool saved = await _saveToGallery(item);
          if (saved) {
            onCompleted?.call(item);
          } else {
            item.status.value = DownloadTaskStatus.failed;
            onError?.call(item, "Downloaded file is corrupted or too small");
          }
          _removeTask(item);
        } else if (item.status.value == DownloadTaskStatus.failed) {
          print("download failed");
          AppUtil.showNormalToast("URL is unavailable. Please try another method.".tr);
          await _recoverIfFileExists(item); // quan trọng để fix false failed
          onError?.call(item, "Download failed");
          _removeTask(item);
        }
      });

      FlutterDownloader.registerCallback(_downloadCallback, step: 1);
      _isInitialized = true;
    } catch (e) {
      print("Lỗi khởi tạo VideoDownloadHelper: $e");
      _isInitialized = false;
      _initFuture = null;
    }
  }

  @pragma('vm:entry-point')
  static void _downloadCallback(String id, int status, int progress) {
    final send = IsolateNameServer.lookupPortByName(_portName);
    send?.send([id, status, progress]);
  }

  String _buildFFmpegHeaders(Map<String, String>? headers) {
    if (headers == null || headers.isEmpty) return "";
    final sb = StringBuffer();
    headers.forEach((key, value) {
      final cleanValue = value.replaceAll('\r', '').replaceAll('\n', '');
      sb.write("$key: $cleanValue\r\n");
    });
    return '-headers "${sb.toString()}" ';
  }

  Future<void> downloadM3u8(DownloadItem item) async {
    final tempDir = await getApplicationDocumentsDirectory();
    final outputPath = '${tempDir.path}/${item.fileName}';

    final headerStr = _buildFFmpegHeaders(item.headers);

    // Bước 1: Lấy thông tin video để biết tổng thời lượng (Duration)
    final session = await FFmpegKit.execute("$headerStr-i \"${item.videoUrl}\"");
    final output = await session.getOutput();

    // Parse thời lượng từ log (định dạng Duration: 00:00:10.00)
    RegExp regExp = RegExp(r"Duration: (\d{2}):(\d{2}):(\d{2})\.(\d{2})");
    Match? match = regExp.firstMatch(output ?? "");

    if (match != null) {
      int hours = int.parse(match.group(1)!);
      int minutes = int.parse(match.group(2)!);
      int seconds = int.parse(match.group(3)!);
      item.totalDurationMs = (hours * 3600 + minutes * 60 + seconds) * 1000.0;
    }

    // Bước 2: Bắt đầu tải và convert
    final ffmpegCommand = '$headerStr-i "${item.videoUrl}" -c copy -bsf:a aac_adtstoasc "$outputPath" -y';

    await FFmpegKit.executeAsync(
        ffmpegCommand,
        (session) async {
          // Callback khi hoàn thành
          final returnCode = await session.getReturnCode();
          if (ReturnCode.isSuccess(returnCode)) {
            item.progress.value = 1.0;
            item.status.value = DownloadTaskStatus.complete;
            bool saved = await _saveToGallery(item);
            if (saved) {
              onCompleted?.call(item);
            } else {
              item.status.value = DownloadTaskStatus.failed;
              onError?.call(item, "Downloaded file is corrupted or too small");
            }
            _removeTask(item);
          } else {
            item.status.value = DownloadTaskStatus.failed;
            onError?.call(item, "FFmpeg error");
            _removeTask(item);
          }
        },
        (log) => print(log.getMessage()), // LogCallback
        (statistics) {
          // StatisticsCallback: Nơi tính progress
          if (item.totalDurationMs > 0) {
            // time là thời gian đã xử lý được (tính bằng miliseconds)
            double timeInMs = statistics.getTime().toDouble();
            double progress = timeInMs / item.totalDurationMs;

            // Giới hạn progress từ 0.0 đến 0.95 (để dành 5% cho việc finalize file)
            if (progress <= 0.95) {
              item.progress.value = progress;

              // Trigger UI update thông qua throttle giống như cũ
              final now = DateTime.now();
              if (_lastUiUpdateTime == null ||
                  now.difference(_lastUiUpdateTime!).inMilliseconds >= 400) {
                _lastUiUpdateTime = now;
                onProgressChanged?.call(item);
              }
            }
          }
        }
    );
  }

  Future<void> downloadAndMerge(DownloadItem item) async {
    final tempDir = await getApplicationDocumentsDirectory();
    final outputPath = '${tempDir.path}/${item.fileName}';

    final headerStr = _buildFFmpegHeaders(item.headers);

    // Lệnh gộp luồng video và luồng audio sử dụng FFmpeg copy cực kỳ nhanh
    final ffmpegCommand = '$headerStr-i "${item.videoUrl}" $headerStr-i "${item.audioUrl}" -c:v copy -c:a aac -map 0:v:0 -map 1:a:0 "$outputPath" -y';

    await FFmpegKit.executeAsync(
        ffmpegCommand,
        (session) async {
          // Callback khi hoàn thành
          final returnCode = await session.getReturnCode();
          if (ReturnCode.isSuccess(returnCode)) {
            item.progress.value = 1.0;
            item.status.value = DownloadTaskStatus.complete;
            bool saved = await _saveToGallery(item);
            if (saved) {
              onCompleted?.call(item);
            } else {
              item.status.value = DownloadTaskStatus.failed;
              onError?.call(item, "Downloaded file is corrupted or too small");
            }
            _removeTask(item);
          } else {
            item.status.value = DownloadTaskStatus.failed;
            onError?.call(item, "FFmpeg merge error");
            _removeTask(item);
          }
        },
        (log) => print(log.getMessage()), // LogCallback
        (statistics) {
          // StatisticsCallback: Nơi tính progress
          if (item.totalDurationMs > 0) {
            double timeInMs = statistics.getTime().toDouble();
            double progress = timeInMs / item.totalDurationMs;

            if (progress <= 0.95) {
              item.progress.value = progress;

              // Trigger UI update thông qua throttle
              final now = DateTime.now();
              if (_lastUiUpdateTime == null ||
                  now.difference(_lastUiUpdateTime!).inMilliseconds >= 400) {
                _lastUiUpdateTime = now;
                onProgressChanged?.call(item);
              }
            }
          }
        }
    );
  }

  /// Bắt đầu download một video
  Future<String?> download({
    required String videoUrl,
    String? audioUrl,
    double? duration,
    String? fileName,
    required String title,
    required DownloadType type,
    String? size,
    Map<String, String>? headers,
    Function(DownloadItem)? onStart,
  }) async {
    await initialize();

    try {
      print("start download video: $videoUrl, audio: $audioUrl");
      final tempDir = await getApplicationDocumentsDirectory();
      if (!await tempDir.exists()) {
        await tempDir.create(recursive: true);
      }
      final saveFileName = fileName ?? 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';

      if (audioUrl != null && audioUrl.isNotEmpty) {
        print("Phát hiện audioUrl, sử dụng FFmpeg gộp...");
        final taskId = "ffmpeg_merge_${DateTime.now().millisecondsSinceEpoch}";
        final item = DownloadItem(taskId, videoUrl, saveFileName, title, type, audioUrl: audioUrl, duration: duration, size: size, headers: headers);
        activeDownloads.add(item);
        _taskMap[taskId] = item;

        onStart?.call(item);
        onProgressChanged?.call(item);

        downloadAndMerge(item);
        return taskId;
      }

      if (videoUrl.toLowerCase().contains(".m3u8")) {
        print("Phát hiện định dạng M3U8, sử dụng FFmpeg...");

        // Tạo một taskId giả lập vì FFmpeg không tự sinh taskId như FlutterDownloader
        final taskId = "ffmpeg_${DateTime.now().millisecondsSinceEpoch}";

        final item = DownloadItem(taskId, videoUrl, saveFileName, title, type, duration: duration, size: size, headers: headers);
        activeDownloads.add(item);
        _taskMap[taskId] = item;

        onStart?.call(item);
        onProgressChanged?.call(item);

        // Gọi hàm download bằng FFmpeg (hàm này chạy async bên trong)
        downloadM3u8(item);

        return taskId;
      }
      final taskId = await FlutterDownloader.enqueue(
        url: videoUrl,
        savedDir: tempDir.path,
        fileName: saveFileName,
        showNotification: true,
        openFileFromNotification: false,
        headers: headers ?? {},
      );

      if (taskId == null) return null;

      final item = DownloadItem(taskId, videoUrl, saveFileName, title, type, duration: duration, size: size, headers: headers);
      activeDownloads.add(item);
      _taskMap[taskId] = item;

      onStart?.call(item);
      onProgressChanged?.call(item); // update UI ban đầu

      return taskId;
    } catch (e) {
      print("Lỗi khi bắt đầu tải video: $e");
      AppUtil.showNormalToast("Something went wrong while starting the download.".tr);
      return null;
    }
  }


  Future<bool> _saveToGallery(DownloadItem item) async {
    try {
      // Trước khi save gallery: delay 1 giây
      await Future.delayed(const Duration(seconds: 1));

      final tempDir = await getApplicationDocumentsDirectory();
      final filePath = '${tempDir.path}/${item.fileName}';
      print("Lưu video vào thư viện từ file: $filePath");
      print("Video title: ${item.title}, type: ${item.type.name}");
      var file = File(filePath);

      if (!await file.exists()) {
        print("File does not exist: $filePath");
        return false;
      }

      int sizeBytes = await file.length();
      print("Downloaded file size: $sizeBytes bytes");
      if (sizeBytes < 20 * 1024) {
        print("File size is less than 20KB: $sizeBytes bytes => download lỗi");
        AppUtil.showNormalToast("Downloaded file is too small or corrupted.".tr);
        try {
          await file.delete();
        } catch (_) {}
        return false;
      }

      // Verify playable trước khi save:
      final infoSession = await FFprobeKit.getMediaInformation(filePath);
      final mediaInfo = infoSession.getMediaInformation();
      if (mediaInfo == null) {
        print("FFprobe failed: mediaInfo is null => reject file");
        AppUtil.showNormalToast("Downloaded file is corrupted.".tr);
        try {
          await file.delete();
        } catch (_) {}
        return false;
      }

      String? durationStr = mediaInfo.getDuration();
      final streams = mediaInfo.getStreams();
      StreamInformation? videoStream;
      try {
        videoStream = streams.firstWhere((s) => s.getType() == "video");
      } catch (_) {}

      final width = videoStream?.getWidth() ?? 0;
      final height = videoStream?.getHeight() ?? 0;

      print("FFprobe validation - duration: $durationStr, width: $width, height: $height");

      if (durationStr == null || width == 0 || height == 0) {
        print("Reject file: duration is null or resolution is 0x0");
        AppUtil.showNormalToast("Downloaded file is not a valid video.".tr);
        try {
          await file.delete();
        } catch (_) {}
        return false;
      }

      // Proceed to save video
      String? saveUri;
      try {
        saveUri = await MediaStoreHelper.saveVideo(
          sourcePath: filePath,
          displayName: item.title
        );
      } catch (e) {
        print("Lỗi khi gọi MediaStoreHelper.saveVideo: $e");
      }
      print("run here after save video: $saveUri");

      String sizeStr = item.size ?? "";
      if (sizeStr.isEmpty) {
        sizeStr = MediaStoreHelper.convertFileSizeToString(sizeBytes);
      }

      int durationSec = 0;
      try {
        durationSec = double.parse(durationStr).toInt();
      } catch (_) {
        if (item.totalDurationMs > 0) {
          durationSec = (item.totalDurationMs / 1000).toInt();
        }
      }

      List<int>? thumbnail;
      try {
        thumbnail = await MediaStoreHelper.getThumbnailFile(file);
      } catch (e) {
        print("Lỗi khi tạo thumbnail: $e");
      }

      var downloadModel = DownloadRealmModel(
        ObjectId(),
        saveUri ?? filePath,
        "video",
        item.title,
        sizeStr,
        durationSec,
        item.type.name.toLowerCase(),
        DateTime.now(),
        thumbnail: thumbnail ?? [],
      );

      var realm = AppSetting.realm;
      realm.write(() {
        realm.add<DownloadRealmModel>(downloadModel);
      });

      if (Get.isRegistered<HistoryTabController>()) {
        var historyController = Get.isRegistered<HistoryTabController>() ? Get.find<HistoryTabController>() : Get.put(HistoryTabController());
        historyController.getData();
        try {
          historyController.tabController.animateTo(1, duration: const Duration(milliseconds: 300));
        } catch (_) {}
      }
      if (Get.isRegistered<DownloadDetailController>()) {
        var controller = Get.isRegistered<DownloadDetailController>() ? Get.find<DownloadDetailController>() : Get.put(DownloadDetailController());
        controller.getData();
        try {
          controller.tabController.animateTo(2, duration: const Duration(milliseconds: 300));
        } catch (_) {}
      }

      print("Lưu video vào thư viện thành công: ${saveUri ?? filePath}");
      AppUtil.showDownloadSuccessPopup();
      return true;
    } catch (e) {
      print("Lỗi khi lưu video vào thư viện: $e");
      AppUtil.showNormalToast("Failed to save video to gallery.".tr);
      return false;
    }
  }

  Future<void> _recoverIfFileExists(DownloadItem item) async {
    try {
      final tempDir = await getApplicationDocumentsDirectory();
      final filePath = '${tempDir.path}/${item.fileName}';
      final file = File(filePath);

      if (await file.exists() && await file.length() > 20 * 1024) { // > 20KB để chắc chắn không phải file rỗng
        await Gal.putVideo(filePath);
        AppUtil.showDownloadSuccessPopup();
        item.status.value = DownloadTaskStatus.complete;
        onCompleted?.call(item);
        _removeTask(item);
      }
    } catch (_) {}
  }

  void _removeTask(DownloadItem item) {
    activeDownloads.remove(item);
    _taskMap.remove(item.taskId);
  }

  // Các hàm điều khiển task
  Future<void> pause(String taskId) => FlutterDownloader.pause(taskId: taskId);
  Future<void> resume(String taskId) => FlutterDownloader.resume(taskId: taskId);
  Future<void> cancel(String taskId) async {
    await FlutterDownloader.cancel(taskId: taskId);
    final item = _taskMap[taskId];
    if (item != null) {
      _removeTask(item);
      onProgressChanged?.call(item);
    }
  }

  // Lấy item theo taskId (dùng trong UI)
  DownloadItem? getTask(String taskId) => _taskMap[taskId];


  // Cleanup khi app đóng hoặc screen dispose
  void dispose() {
    IsolateNameServer.removePortNameMapping(_portName);
    activeDownloads.clear();
    _taskMap.clear();
  }
}