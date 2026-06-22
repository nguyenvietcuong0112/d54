

class FormatModel {
  late String formatId;
  late double height;
  late double width;
  late String ext;
  late double fileSize;
  late String url;
  late String title;
  late String thumbnailUrl;
  late String vcodec;
  late String acodec;

  FormatModel({
    required this.formatId,
    required this.height,
    required this.width,
    required this.ext,
    required this.fileSize,
    required this.url,
    required this.title,
    required this.thumbnailUrl,
    required this.vcodec,
    required this.acodec,
  });

  factory FormatModel.fromJson(Map<String, dynamic> json, String title, String thumbnailUrl) {
    return FormatModel(
      formatId: json['format_id'] ?? "",
      height: (json['height'] as num?)?.toDouble() ?? 0.0,
      width: (json['width'] as num?)?.toDouble() ?? 0.0,
      ext: json['ext'] ?? "",
      fileSize: (json['filesize'] as num?)?.toDouble() ?? 0.0,
      url: json['url'] ?? "",
      title: title,
      thumbnailUrl: thumbnailUrl,
      vcodec: json['vcodec'] ?? "",
      acodec: json['acodec'] ?? "",
    );
  }
}