import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 家計簿アプリにサインインするための操作をまとめたヘルパー関数
Future<void> singInApp(
  WidgetTester tester,
  String email,
  String password,
) async {
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
    password,
  );
  await tester.tap(
    find.byWidgetPredicate(
      (widget) =>
          widget is OutlinedButton &&
          (widget.child as dynamic)!.label == "Sign in",
      description: "with sign in button",
    ),
  );
}
