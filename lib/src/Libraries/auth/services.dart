// google_auth_service.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<User?> signInWithGoogle({
    required BuildContext context,
    required Function(String message) onMessage,
  }) async {
    try {
      // 1. Initialize GoogleSignIn
      await _googleSignIn.initialize();

      // 2. Attempt silent sign-in first
      GoogleSignInAccount? googleUser =
      await _googleSignIn.attemptLightweightAuthentication();

      // 3. Interactive sign-in if needed
      if (googleUser == null) {
        googleUser = await _googleSignIn.authenticate();
      }

      // 4. User cancelled
      if (googleUser == null) {
        onMessage("Google Sign-In was cancelled.");
        return null;
      }

      // 5. Get tokens
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception("Authentication failed: No ID token received.");
      }

      // 6. Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.idToken, // ✅ fixed here
        idToken: idToken,
      );

      // 7. Sign in to Firebase
      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        onMessage("Welcome, ${user.displayName}!");
      }

      return user;
    } on FirebaseAuthException catch (e) {
      onMessage("Firebase Sign-In failed: ${e.message}");
      return null;
    } catch (error) {
      onMessage("An unexpected error occurred: $error");
      return null;
    }
  }

  Future<void> signOut({
    required Function(String message) onMessage,
  }) async {
    try {
      await FirebaseAuth.instance.signOut();
      await _googleSignIn.signOut();
      onMessage("Signed out successfully!");
    } catch (e) {
      onMessage("Sign out failed: $e");
    }
  }
}