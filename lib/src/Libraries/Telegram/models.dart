import 'dart:convert';

class FileUploader {
  String size;
  String thumbnailUrl;
  String fileUrl;
  int fileMessageId, thumbnailMessageId;
  String fileName;
  String type;

  FileUploader({
    required this.size,
    required this.thumbnailUrl,
    required this.fileUrl,
    required this.fileMessageId,
    required this.thumbnailMessageId,
    required this.fileName,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'size': size,
      'thumbnailUrl': thumbnailUrl,
      'fileUrl': fileUrl,
      'fileMessageId': fileMessageId,
      'thumbnailMessageId': thumbnailMessageId,
      'fileName': fileName,
      'type': type,
    };
  }

  factory FileUploader.fromJson(Map<String, dynamic> json) {
    return FileUploader(
      size: json['size'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      fileMessageId: json['fileMessageId'] ?? 0,
      thumbnailMessageId: json['thumbnailMessageId'] ?? 0,
      fileName: json['fileName'] ?? '',
      type: json['type'] ?? '',
    );
  }

  static List<FileUploader> fromMapList(List<dynamic> list) {
    return list.map((item) => FileUploader.fromJson(Map<String, dynamic>.from(item))).toList();
  }
}

class MediaInfoOld {
  final int width;
  final int height;
  final String fileId;
  final int fileSize;

  MediaInfoOld({required this.width, required this.height, required this.fileId, required this.fileSize});

  Map<String, dynamic> toJson() => {
    'width': width,
    'height': height,
    'file_id': fileId,
    'file_size': fileSize,
  };

  factory MediaInfoOld.fromJson(Map<String, dynamic> json) => MediaInfoOld(
    width: json['width'] ?? 0,
    height: json['height'] ?? 0,
    fileId: json['file_id'] ?? '',
    fileSize: json['file_size'] ?? 0,
  );
}

class FileConvertor {
  String? size;
  MediaInfoOld? thumb;
  String? url;
  String? name;
  String? type;

  FileConvertor({this.size, this.thumb, this.url, this.name, this.type});

  Map<String, dynamic> toJson() => {
    'size': size ?? "",
    'thumb': thumb?.toJson() ?? {},
    'url': url ?? "",
    'name': name ?? "",
    'type': type ?? "",
  };

  factory FileConvertor.fromJson(Map<String, dynamic> json) => FileConvertor(
    size: json['size'] ?? "",
    thumb: json['thumb'] != null ? MediaInfoOld.fromJson(Map<String, dynamic>.from(json['thumb'])) : null,
    url: json['url'] ?? "",
    name: json['name'] ?? "",
    type: json['type'] ?? "",
  );

  static List<FileConvertor> fromJsonList(List<dynamic> list) {
    return list.map((item) => FileConvertor.fromJson(Map<String, dynamic>.from(item))).toList();
  }
}

class FileShare {
  final int id;
  final String url;

  FileShare({required this.id, required this.url});

  Map<String, dynamic> toJson() => {
    'id': id,
    'url': url,
  };

  static FileShare fromJson(Map<String, dynamic> json) {
    return FileShare(
      id: json['id'] ?? 0,
      url: json['url'] ?? '',
    );
  }
}

class NotificationConverterForOrders {
  final DateTime date;
  final String title;
  final String body;

  NotificationConverterForOrders({required this.date, required this.title, required this.body});

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'title': title,
    'body': body,
  };

  static NotificationConverterForOrders fromJson(Map<String, dynamic> json) {
    return NotificationConverterForOrders(
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      title: json['title'] ?? '',
      body: json['body'] ?? '',
    );
  }
}

class UploadResult<T> {
  final bool success;
  final T? data;
  final String? error;

  UploadResult._({required this.success, this.data, this.error});

  factory UploadResult.success(T data) =>
      UploadResult._(success: true, data: data);

  factory UploadResult.failure(String error) =>
      UploadResult._(success: false, error: error);
}