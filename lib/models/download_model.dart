

import 'package:cscmobi_app/models/format_model.dart';

class DownloadModel {
  late String title;
  late String thumbnail;
  late double duration; // in seconds
  late String source;
  late List<FormatModel> formats;

  DownloadModel({
    required this.title,
    required this.thumbnail,
    required this.duration,
    required this.source,
    this.formats = const [],
  });

  factory DownloadModel.fromJson(Map<String, dynamic> json) {
    return DownloadModel(
      title: json['title'] ?? "",
      thumbnail: json['thumbnail'] ?? "",
      duration: (json['duration'] ?? 0 as num).toDouble(),
      source: json['source'] ?? "",
      formats: (json['formats'] as List<dynamic>?)
          ?.map((e) => FormatModel.fromJson(e, json['title'] ?? "", json['thumbnail'] ?? ""))
          .toList() ?? [],
    );
  }
}