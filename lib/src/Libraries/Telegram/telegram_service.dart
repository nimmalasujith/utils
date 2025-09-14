import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'models.dart';

class TelegramService {
  final String botToken;
  final String chatId;
  final http.Client _client = http.Client();

  TelegramService({
    required this.botToken,
    required this.chatId,
  });

  String get baseUrl => "https://api.telegram.org/bot$botToken";

  /// Upload a file with progress tracking
  Future<UploadResult<FileShare>> sendDocument(
      String filePath, {
        void Function(double progress)? onProgress,
      }) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      return UploadResult.failure("File not found");
    }
    if (file.lengthSync() > 20 * 1024 * 1024) {
      return UploadResult.failure("File exceeds 20MB limit");
    }

    final url = Uri.parse("$baseUrl/sendDocument");
    final request = http.MultipartRequest("POST", url);
    request.fields["chat_id"] = chatId;

    final length = await file.length();
    int uploadedBytes = 0;

    final stream = file.openRead().transform(
      StreamTransformer<List<int>, List<int>>.fromHandlers(
        handleData: (chunk, sink) {
          uploadedBytes += chunk.length;
          if (onProgress != null) {
            onProgress(uploadedBytes / length);
          }
          sink.add(chunk);
        },
      ),
    );

    request.files.add(
      http.MultipartFile(
        "document",
        stream,
        length,
        filename: file.uri.pathSegments.last,
      ),
    );

    final response = await _client.send(request);
    final body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(body);
      final result = FileShare(
        id: jsonBody["result"]["message_id"],
        url: jsonBody["result"]["document"]["file_id"],
      );
      return UploadResult.success(result);
    }

    return UploadResult.failure("Upload failed: $body");
  }

  /// Download a file with progress
  Future<UploadResult<String>> downloadFileByFileId(
      String fileId,
      String savePath, {
        void Function(double progress)? onProgress,
      }) async {
    final info = await getFileInfo(fileId);
    if (info == null) {
      return UploadResult.failure("Could not fetch file info");
    }

    final fileUrl = "https://api.telegram.org/file/bot$botToken/${info.filePath}";
    final request = http.Request("GET", Uri.parse(fileUrl));
    final response = await _client.send(request);

    if (response.statusCode != 200) {
      return UploadResult.failure("Download failed with ${response.statusCode}");
    }

    final contentLength = response.contentLength ?? 0;
    int received = 0;

    final file = File(savePath);
    final sink = file.openWrite();

    await response.stream.listen(
          (chunk) {
        received += chunk.length;
        sink.add(chunk);
        if (onProgress != null && contentLength > 0) {
          onProgress(received / contentLength);
        }
      },
      onDone: () async {
        await sink.close();
      },
      onError: (e) {
        sink.close();
      },
      cancelOnError: true,
    ).asFuture();

    return UploadResult.success(savePath);
  }

  /// Get Telegram file info by fileId
  Future<_TelegramFileInfo?> getFileInfo(String fileId) async {
    final url = Uri.parse("$baseUrl/getFile?file_id=$fileId");
    final response = await _client.get(url);
    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      final path = jsonBody["result"]["file_path"];
      return _TelegramFileInfo(fileId: fileId, filePath: path);
    }
    return null;
  }

  Future<bool> deleteMessage(int messageId) async {
    final url = Uri.parse("$baseUrl/deleteMessage");
    final response = await _client.post(url, body: {
      "chat_id": chatId,
      "message_id": messageId.toString(),
    });
    return response.statusCode == 200;
  }

  Future<bool> editMessageText(int messageId, String newText) async {
    final url = Uri.parse("$baseUrl/editMessageText");
    final response = await _client.post(url, body: {
      "chat_id": chatId,
      "message_id": messageId.toString(),
      "text": newText,
    });
    return response.statusCode == 200;
  }
}

class _TelegramFileInfo {
  final String fileId;
  final String filePath;
  _TelegramFileInfo({required this.fileId, required this.filePath});
}