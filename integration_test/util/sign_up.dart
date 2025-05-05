import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 家計簿アプリにサインアップするための操作をまとめたヘルパー関数
Future<void> signUpApp(WidgetTester tester, String email) async {
  await tester.tap(find.textContaining("Register"));
  await tester.pumpAndSettle();

  await tester.enterText(
    find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration!.labelText == "Email",
      description: "with email text field",
    ),
    email,
  );
  await tester.enterText(
    find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration!.labelText == "Password",
      description: "with password text field",
    ),
    "password",
  );
  await tester.enterText(
    find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration!.labelText == "Confirm password",
      description: "with confirm password text field",
    ),
    "password",
  );
  await tester.tap(
    find.byWidgetPredicate(
      (widget) =>
          widget is OutlinedButton &&
          (widget.child as dynamic)!.label == "Register",
      description: "with register button",
    ),
  );

  // Display loading screen of MyAppHome
  await tester.pump();
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
}
