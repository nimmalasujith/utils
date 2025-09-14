import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LogOutWidget extends StatefulWidget {
  final void Function()? onLogoutSuccess;
  final void Function(String error)? onLogoutFailed;

  const LogOutWidget({
    super.key,
    this.onLogoutSuccess,
    this.onLogoutFailed,
  });

  @override
  State<LogOutWidget> createState() => _LogOutWidgetState();
}

class _LogOutWidgetState extends State<LogOutWidget> {
  final User? user = FirebaseAuth.instance.currentUser;

  Future<void> _handleLogout() async {
    try {
      if (user != null && user!.isAnonymous) {
        await user!.delete(); // delete anonymous account
      }

      await FirebaseAuth.instance.signOut(); // Firebase sign out

      widget.onLogoutSuccess?.call(); // trigger callback
    } catch (e) {
      widget.onLogoutFailed?.call(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 100.0),
      child: GestureDetector(
        onTap: _handleLogout,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          margin: const EdgeInsets.only(top: 20),
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade900,
            borderRadius: BorderRadius.circular(25),
          ),
          alignment: Alignment.center,
          child: Text(
            (user != null && user!.isAnonymous)
                ? 'Logout & Delete Account'
                : "Logout",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}