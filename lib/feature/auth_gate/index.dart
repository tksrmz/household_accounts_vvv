import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as ui;
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../presentation/app_home_page/page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User?>();

    if (user == null) {
      return ui.SignInScreen(
        providers: [
          ui.EmailAuthProvider(),
        ],
      );
    }

    return MyAppHome(uid: user.uid);
  }
}
