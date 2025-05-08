import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/main.dart';

import 'util/sign_in.dart';

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

  testWidgets('ユーザー名が20文字を超えると保存ボタンが無効になる', (tester) async {
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
    await tester.tap(find.text("NewUsername"));
    await tester.pumpAndSettle();

    // Enter a username that is too long (21 characters)
    await tester.enterText(find.byType(TextField), "ThisUsernameIsTooLonggg");
    await tester.pumpAndSettle();

    // Verify error message is shown
    expect(find.text("ユーザー名は最大20文字までにしてください"), findsOneWidget);

    // Verify save button is disabled
    final saveButton = find.text("保存");
    expect(
        tester
            .widget<ElevatedButton>(find.ancestor(
              of: saveButton,
              matching: find.byType(ElevatedButton),
            ))
            .enabled,
        isFalse);

    // Enter a valid username
    await tester.enterText(find.byType(TextField), "ValidUsername");
    await tester.pumpAndSettle();

    // Verify error message is gone
    expect(find.text("ユーザー名は最大20文字までにしてください"), findsNothing);

    // Verify save button is enabled
    expect(
        tester
            .widget<ElevatedButton>(find.ancestor(
              of: saveButton,
              matching: find.byType(ElevatedButton),
            ))
            .enabled,
        isTrue);
  });

  testWidgets(
    'ユーザー名の保存に失敗するとエラーメッセージが表示される',
    (tester) async {
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
      await tester.tap(find.text("ValidUsername"));
      await tester.pumpAndSettle();

      // Enter new username that will trigger a save error
      // Note: The actual implementation should have a way to simulate save failure
      await tester.enterText(find.byType(TextField), "ErrorUsername");
      await tester.pumpAndSettle();

      // Try to save the changes
      await tester.tap(find.text("保存"));
      await tester.pumpAndSettle();

      // Verify error message is shown in snackbar
      expect(find.text("ユーザー名の保存に失敗しました"), findsOneWidget);

      // Verify the username reverted to the original value
      expect(find.text("ValidUsername"), findsOneWidget);
    },
    skip: true,
  ); // FIXME: This test is skipped because the error simulation is not implemented yet.
}
