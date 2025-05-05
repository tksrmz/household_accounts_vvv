import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/main.dart';

import 'util.dart';

Future<void> propertyFeature() async {
  testWidgets('ユーザーは自分の家計簿で資産を管理できる', (tester) async {
    await tester.pumpWidget(const MyApp());
    await singInApp(tester, "single_user@example.com", "abc1234");

    // Wait for loading to finish
    await tester.pumpAndSettle();

    // Navigate to property screen using bottom navigation bar
    await tester.tap(find.text('資産'));
    await tester.pumpAndSettle();

    // Add new property
    await tester.tap(find.text('資産の追加'));
    await tester.pumpAndSettle();

    // Enter property details
    await tester.enterText(find.widgetWithText(TextField, '資産名'), '普通預金');
    await tester.enterText(find.widgetWithText(TextField, '資産額'), '100000');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    // Verify property is created
    expect(find.text('普通預金'), findsOneWidget);
    expect(find.text('¥100,000'), findsOneWidget);

    // Add another property
    await tester.tap(find.text('資産の追加'));
    await tester.pumpAndSettle();

    // Enter another property details
    await tester.enterText(find.widgetWithText(TextField, '資産名'), '現金');
    await tester.enterText(find.widgetWithText(TextField, '資産額'), '30000');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    // Verify both properties exist
    expect(find.text('普通預金'), findsOneWidget);
    expect(find.text('¥100,000'), findsOneWidget);
    expect(find.text('現金'), findsOneWidget);
    expect(find.text('¥30,000'), findsOneWidget);

    // Edit property
    await tester.tap(find.widgetWithIcon(IconButton, Icons.edit).first);
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, '資産名'), '普通預金（メイン）');
    await tester.enterText(find.widgetWithText(TextField, '資産額'), '120000');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    // Verify property is updated
    expect(find.text('普通預金（メイン）'), findsOneWidget);
    expect(find.text('¥120,000'), findsOneWidget);
    expect(find.text('普通預金'), findsNothing);
    expect(find.text('¥100,000'), findsNothing);

    // Delete property
    await tester.tap(find.widgetWithIcon(IconButton, Icons.delete).first);
    await tester.pumpAndSettle();

    // Verify property is deleted
    expect(find.text('普通預金（メイン）'), findsNothing);
    expect(find.text('¥120,000'), findsNothing);
  });

  testWidgets('ペアリング済みユーザーはふたりの家計簿で資産を管理できる', (tester) async {
    await tester.pumpWidget(const MyApp());
    await singInApp(tester, "pair_user_a@example.com", "abc1234");

    // Wait for loading to finish
    await tester.pumpAndSettle();

    // Open the navigation menu to switch to shared account
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    // Switch to shared household account
    await tester.tap(find.text('ふたりの家計簿を見る'));
    await tester.pumpAndSettle();

    // Navigate to property screen using bottom navigation bar
    await tester.tap(find.text('資産'));
    await tester.pumpAndSettle();

    // Add new shared property
    await tester.tap(find.text('資産の追加'));
    await tester.pumpAndSettle();

    // Enter shared property details
    await tester.enterText(find.widgetWithText(TextField, '資産名'), '共同口座');
    await tester.enterText(find.widgetWithText(TextField, '資産額'), '200000');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    // Verify shared property is created
    expect(find.text('共同口座'), findsOneWidget);
    expect(find.text('¥200,000'), findsOneWidget);

    // Edit shared property
    await tester.tap(find.widgetWithIcon(IconButton, Icons.edit).first);
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextField, '資産名'), '共同口座（住宅ローン）');
    await tester.enterText(find.widgetWithText(TextField, '資産額'), '250000');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    // Verify shared property is updated
    expect(find.text('共同口座（住宅ローン）'), findsOneWidget);
    expect(find.text('¥250,000'), findsOneWidget);
    expect(find.text('共同口座'), findsNothing);
    expect(find.text('¥200,000'), findsNothing);

    // Delete shared property
    await tester.tap(find.widgetWithIcon(IconButton, Icons.delete).first);
    await tester.pumpAndSettle();

    // Verify shared property is deleted
    expect(find.text('共同口座（住宅ローン）'), findsNothing);
    expect(find.text('¥250,000'), findsNothing);
  });
}
