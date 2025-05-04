import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/main.dart';

import 'util.dart';

Future<void> userNameFeature() async {
  testWidgets('ユーザーは設定画面で自分のユーザー名を確認できる', (tester) async {
    await tester.pumpWidget(const MyApp());
    await singInApp(tester, "single_user@example.com", "abc1234");

    // Display loading screen
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for loading to finish.
    // The number of pumps will not be checked as it does not matter that how long it takes
    await tester.pumpAndSettle();

    // Open the navigation menu
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    // Open setting screen
    await tester.tap(find.text("設定"));
    await tester.pumpAndSettle();

    // Check user name
    expect(find.text("ユーザー名"), findsOneWidget);
    expect(find.text("Hoge"), findsOneWidget);
  });
}
