// google_login_button.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:utils/src/Libraries/auth/services.dart';

class GoogleLoginButton extends StatefulWidget {
  final List<String>? scopes;
  final Widget Function(bool loading) builder;
  final void Function(User user)? onLoginSuccess;
  final void Function()? onLoginCancelled;
  final void Function()? onLoginFailed;

  const GoogleLoginButton({
    Key? key,
    required this.builder,
    this.onLoginSuccess,
    this.scopes,
    this.onLoginCancelled,
    this.onLoginFailed,
  }) : super(key: key);

  @override
  State<GoogleLoginButton> createState() => _GoogleLoginButtonState();
}

class _GoogleLoginButtonState extends State<GoogleLoginButton> {
  bool _loading = false;
  late GoogleAuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = GoogleAuthService(initialScopes: widget.scopes ?? []); // no constructor params

  }

  Future<void> _handleLogin() async {
    if (_loading) return;

    setState(() => _loading = true);

    final user = await _authService.signInWithGoogle(
      context: context,
      onMessage: (msg) => debugPrint("GoogleAuth: $msg"),


    );

    if (!mounted) return;

    if (user != null) {
      widget.onLoginSuccess?.call(user);
    } else {
      widget.onLoginFailed?.call();
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _handleLogin,
      borderRadius: BorderRadius.circular(30),
      child: widget.builder(_loading),
    );
  }
}