import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for sending notifications via FCM (HTTP v1 API)
class FCMService {
  final String projectId;
  final String accessToken; // From oauth_token.dart

  FCMService({
    required this.projectId,
    required this.accessToken,
  });

  /// Send push notification
  Future<bool> sendNotification({
    required String targetToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    final url = Uri.parse(
      "https://fcm.googleapis.com/v1/projects/$projectId/messages:send",
    );

    final message = {
      "message": {
        "token": targetToken,
        "notification": {"title": title, "body": body},
        "data": data ?? {}
      }
    };

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
      body: jsonEncode(message),
    );

    return response.statusCode == 200;
  }
}