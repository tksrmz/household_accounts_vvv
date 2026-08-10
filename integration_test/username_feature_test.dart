import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/main.dart';

import 'util/sign_in.dart';
import 'util/sign_up.dart';

Future<void> userNameFeature() async {
  testWidgets('ユーザーは設定画面で自分のユーザー名を変更できる', (tester) async {
    await tester.pumpWidget(const MyApp());
    await signInApp(tester, singleUser);
    await tester.pumpAndSettle();

    // Open the navigation menu
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    // Open setting screen
    await tester.tap(find.text("設定"));
    await tester.pumpAndSettle();

    // Tap the username field to start editing
    await tester.tap(find.text("Hoge"));
    await tester.pumpAndSettle();

    // Enter new username
    await tester.enterText(find.byType(TextField), "NewUsername");
    await tester.pumpAndSettle();

    // Save the changes
    await tester.tap(find.text("保存"));
    await tester.pumpAndSettle();

    // Verify the username was updated
    expect(find.text("NewUsername"), findsOneWidget);
  });

  testWidgets('新規ユーザーは設定画面で自分のユーザー名を変更できる', (tester) async {
    await tester.pumpWidget(const MyApp());
    await signUpApp(tester);
    await tester.pumpAndSettle();

    // Open the navigation menu
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    // Open setting screen
    await tester.tap(find.text("設定"));
    await tester.pumpAndSettle();

    // Tap the username field to start editing
    await tester.tap(
      find.text(FirebaseAuth.instance.currentUser!.uid.substring(0, 5)),
    );
    await tester.pumpAndSettle();

    // Enter new username
    await tester.enterText(find.byType(TextField), "NewUsername");
    await tester.pumpAndSettle();

    // Save the changes
    await tester.tap(find.text("保存"));
    await tester.pumpAndSettle();

    // Verify the username was updated
    expect(find.text("NewUsername"), findsOneWidget);
  });
}
