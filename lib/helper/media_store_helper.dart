
import 'dart:convert';
import 'dart:io';
import 'package:ffmpeg_kit_flutter_new_https/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_https/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new_https/stream_information.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';


class MediaStoreHelper {
  static const _ch = MethodChannel('media_store_audio');

  static Future<bool> deleteFileByUri(String uri) async {
    final success = await _ch.invokeMethod<bool>('deleteFile', {
      'uri': uri,
    });
    return success ?? false;
  }

  static bool _isVideo(String ext) {
    const videoExt = ['.mp4', '.mov', '.avi', '.mkv', '.flv', '.webm'];
    return videoExt.contains(ext);
  }

  static bool _isAudio(String ext) {
    const audioExt = ['.mp3', '.aac', '.wav', '.m4a', '.ogg', '.flac'];
    return audioExt.contains(ext);
  }

  static Future<File> readFile(String uri) async {
    final result = await _ch.invokeMethod<Map>('readFileBytes', {'uri': uri});
    if (result == null) throw Exception("Không đọc được file");

    final Uint8List bytes = Uint8List.fromList(List<int>.from(result['bytes']));
    final String fileName = result['fileName'];

    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/$fileName");
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  /// Lưu file mp3 vào MediaStore/Music. Trả về contentUri (String) nếu OK.
  static Future<String?> saveAudio({
    required String sourcePath,           // đường dẫn file mp3 đã convert
    String? displayName,                  // tên hiển thị (không có thì lấy từ file)
    String album = "VideoDownloader",          // thư mục con trong Music
    String mimeType = "audio/mpeg",       // mp3
  }) async {
    return await _ch.invokeMethod<String>('saveAudio', {
      'sourcePath': sourcePath,
      'displayName': displayName,
      'album': album,
      'mimeType': mimeType,
    });
  }

  static Future<Map<String, dynamic>> getMediaInfo(File file) async {
    final ext = p.extension(file.path).toLowerCase();

    final infoSession = await FFprobeKit.getMediaInformation(file.path);
    final mediaInfo = await infoSession.getMediaInformation();
    if (mediaInfo == null) throw Exception("FFprobe failed");

    // Format container -> lấy phần đầu tiên
    final formatRaw = mediaInfo.getFormat() ?? "";
    final format = p.extension(file.path).replaceAll(".", "").toLowerCase();

    // Size -> byte -> KB / MB
    int sizeBytes = int.tryParse(mediaInfo.getSize() ?? "0") ?? 0;
    String sizeReadable;
    if (sizeBytes >= 1024 * 1024) {
      sizeReadable = "${(sizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB";
    } else {
      sizeReadable = "${(sizeBytes / 1024).toStringAsFixed(2)} KB";
    }

    // Bitrate -> bps -> kbps
    int bitrateBps = int.tryParse(mediaInfo.getBitrate() ?? "0") ?? 0;
    String bitrateReadable =
    bitrateBps > 0 ? "${(bitrateBps / 1000).round()}k" : "N/A";

    // Duration (s)
    double? durationSec;
    try {
      durationSec = double.parse(mediaInfo.getDuration() ?? "0");
    } catch (_) {}

    // Title
    String title = p.basename(file.path);

    final streams = mediaInfo.getStreams();
    StreamInformation? videoStream;

    try {
      videoStream = streams?.firstWhere((s) => s.getType() == "video");
    } catch (e) {
      videoStream = null; // nếu không có stream video
    }

    final width = videoStream?.getWidth() ?? 0;
    final height = videoStream?.getHeight() ?? 0;

    print("Resolution: ${width}x${height}");

    print("Resolution: ${width}x${height}");

    return {
      "title": title,
      "duration": (durationSec ?? 0.0).toInt(),
      "path": file.path,
      "size": sizeReadable,
      "bitrate": bitrateReadable,
      "format": format,
      "width": width,
      "height": height,
    };
  }

  static Future<Uint8List?> getThumbnailFile(File file) async {
    final thumbPath = '${file.path}_thumb.jpg';
    await FFmpegKit.execute('-i "${file.path}" -ss 00:00:01 -vframes 1 -vf "scale=200:-1" "$thumbPath"');

    final thumbFile = File(thumbPath);
    if (await thumbFile.exists()) {
      final bytes = await thumbFile.readAsBytes();
      await thumbFile.delete(); // dọn dẹp
      return bytes;
    }
    return null;
  }

  static Future<Uint8List?> generateThumbnail(String videoUrl) async {
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

  static convertFileSizeToString(int fileSize) {
    int sizeBytes = fileSize;
    String sizeReadable;
    if (sizeBytes >= 1024 * 1024) {
      sizeReadable = "${(sizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB";
    } else {
      sizeReadable = "${(sizeBytes / 1024).toStringAsFixed(2)} KB";
    }
    return sizeReadable;
  }

  static Future<bool> fileExists(String uri) async {
    final exists = await _ch.invokeMethod<bool>('fileExists', {
      'uri': uri,
    });
    return exists ?? false;
  }

  Future<bool> deleteMedia(String uri) async {
    final result = await _ch.invokeMethod("deleteAudio", {
      "uri": uri,
    });
    return result == true;
  }

  static Future<bool> renameAudio({
    required String uri,
    required String displayName,
  }) async {
    return await _ch.invokeMethod<bool>('renameAudio', {
      'uri': uri,
      'displayName': displayName,
    }) ?? false;
  }

  static Future<bool> renameMedia(String uri, String newBaseName) async {
    final result = await _ch.invokeMethod("renameMedia", {
      "uri": uri,
      "newName": newBaseName,
    });
    return result == true;
  }


  static Future<String?> saveVideo({
    required String sourcePath,
    String? displayName,
    String album = "VideoDownloader",
  }) async {
    return await _ch.invokeMethod<String>('saveVideo', {
      'sourcePath': sourcePath,
      'displayName': displayName,
      'album': album,
    });
  }

}