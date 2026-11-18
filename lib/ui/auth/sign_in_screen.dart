import 'package:firebase_ui_auth/firebase_ui_auth.dart' as ui;
import 'package:flutter/material.dart';

/// サインイン画面。
///
/// サインインUIにはfirebase_ui_authを使い続けるが、差し替えられるように
/// このファイルへ隔離している(firebase_ui_authをimportするのは`lib/ui/auth/`だけ)。
/// firebase_ui_auth自身が入力と認証の状態を持つため、ViewModelは作らない。
class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ui.SignInScreen(providers: [ui.EmailAuthProvider()]);
  }
}
