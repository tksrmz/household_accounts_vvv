import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:household_accounts/feature/dashboard/domain/use_case.dart';

import '../dashboard/presentation/index.dart';
import 'use_case.dart';
import 'user.dart';

class AuthGate extends StatelessWidget {
  final AuthUseCase _useCase;

  const AuthGate(AuthUseCase this._useCase, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _useCase.authStateChanges(),
      builder: (context, snapshot) {
        // User is not signed in
        if (!snapshot.hasData) {
          return SignInScreen(
            providers: [
              EmailAuthProvider(),
            ],
          );
        }

        // Render your application if authenticated
        return Dashboard(DashboardUseCase());
      },
    );
  }
}
