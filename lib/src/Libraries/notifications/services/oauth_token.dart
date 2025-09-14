import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Fetch OAuth2 token for Firebase Cloud Messaging (HTTP v1 API)
class OAuthTokenProvider {
  final String serviceAccountPath; // path to serviceAccount.json file

  OAuthTokenProvider({required this.serviceAccountPath});

  Future<String?> getAccessToken() async {
    final serviceAccount = json.decode(await File(serviceAccountPath).readAsString());
    final clientEmail = serviceAccount['client_email'];
    final privateKey = serviceAccount['private_key'];
    final tokenUri = serviceAccount['token_uri'];

    final now = DateTime.now().toUtc();
    final expiry = now.add(Duration(hours: 1));

    // JWT header + claims
    final header = {"alg": "RS256", "typ": "JWT"};
    final claimSet = {
      "iss": clientEmail,
      "scope": "https://www.googleapis.com/auth/firebase.messaging",
      "aud": tokenUri,
      "iat": (now.millisecondsSinceEpoch ~/ 1000),
      "exp": (expiry.millisecondsSinceEpoch ~/ 1000),
    };

    // Normally: sign with crypto library
    // ⚡ To simplify: recommend using package `googleapis_auth` instead
    // This is placeholder for generating a valid JWT

    throw UnimplementedError(
        "Use googleapis_auth package to generate OAuth2 access token.");
  }
}