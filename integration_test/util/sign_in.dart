import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 家計簿アプリにサインインするための操作をまとめたヘルパー関数
Future<void> signInApp(
  WidgetTester tester,
  SignInUserInfo signInUserInfo,
) async {
  await tester.enterText(
    find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration!.labelText == "Email",
      description: "with email text field",
    ),
    signInUserInfo.email,
  );
  await tester.enterText(
    find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration!.labelText == "Password",
      description: "with password text field",
    ),
    signInUserInfo.password,
  );
  await tester.tap(
    find.byWidgetPredicate(
      (widget) =>
          widget is OutlinedButton &&
          (widget.child as dynamic)!.label == "Sign in",
      description: "with sign in button",
    ),
  );

  // Display loading screen of MyAppHome
  await tester.pump();
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
}

class SignInUserInfo {
  final String email;
  final String password;

  const SignInUserInfo({required this.email, required this.password});
}

const singleUser = SignInUserInfo(
  email: 'single_user@example.com',
  password: 'abc1234',
);

const newUser = SignInUserInfo(
  email: 'new_user@example.com',
  password: 'abc1234',
);

const pairUser = SignInUserInfo(
  email: 'pair_user_a@example.com',
  password: 'abc1234',
);
