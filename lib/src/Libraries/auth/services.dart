// google_auth_service.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GoogleAuthService {
  final List<String> _initialScopes;

  GoogleAuthService({ required List<String> initialScopes })
      : _initialScopes = initialScopes;

  /// Must call once before other actions
  Future<void> init({ String? clientId, String? serverClientId }) async {
    await GoogleSignIn.instance.initialize(
      clientId: clientId,             // optional, as per your setup
      serverClientId: serverClientId, // needed on some platforms for server auth codes  [oai_citation:5‡GitHub](https://github.com/flutter/flutter/issues/172073?utm_source=chatgpt.com)
    );
  }

  /// Interactive login
  Future<User?> signInWithGoogle({
    required BuildContext context,
    required Function(String message) onMessage,
  }) async {
    try {
      // initialize
      await init();

      // Try lightweight (silent) authentication first
      GoogleSignInAccount? googleUser =
      await GoogleSignIn.instance.attemptLightweightAuthentication();

      // If silent didn't work, do full authenticate
      if (googleUser == null) {
        googleUser = await GoogleSignIn.instance.authenticate(
          scopeHint: _initialScopes,
        );
      }

      if (googleUser == null) {
        onMessage("Google Sign-In was cancelled or unable to authenticate.");
        return null;
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.idToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        onMessage("Welcome, ${user.displayName}!");
      }

      return user;
    } catch (e) {
      onMessage("Sign-In failed: $e");
      return null;
    }
  }

  /// Request additional scopes after login
  Future<GoogleSignInClientAuthorization?> requestAdditionalScopes(
      GoogleSignInAccount user,
      List<String> extraScopes, {
        required Function(String message) onMessage,
      }) async {
    try {
      final auth = await user.authorizationClient.authorizeScopes(extraScopes);
      if (auth != null) {
        onMessage("Granted extra scopes: ${extraScopes.join(', ')}");
      } else {
        onMessage("User declined extra scopes.");
      }
      return auth;
    } catch (e) {
      onMessage("Request additional scopes failed: $e");
      return null;
    }
  }

  /// Request server auth code if you need backend exchange
  Future<GoogleSignInServerAuthorization?> requestServerAuthCode(
      GoogleSignInAccount user,
      List<String> scopes, {
        required Function(String message) onMessage,
      }) async {
    try {
      final serverAuth = await user.authorizationClient.authorizeServer(scopes);
      if (serverAuth != null) {
        onMessage("Got server auth code.");
      } else {
        onMessage("Server auth not granted.");
      }
      return serverAuth;
    } catch (e) {
      onMessage("Server auth request failed: $e");
      return null;
    }
  }

  Future<void> signOut({ required Function(String message) onMessage }) async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn.instance.signOut();
      onMessage("Signed out successfully!");
    } catch (e) {
      onMessage("Sign out failed: $e");
    }
  }
}