import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/main.dart';

import 'util/sign_up.dart';

Future<void> categoryFeature() async {
  testWidgets('ユーザーは自分の家計簿でカテゴリを管理できるので、収支をカテゴリ別に整理できる', (tester) async {
    await tester.pumpWidget(const MyApp());
    await signUpApp(tester);

    // Wait for loading to finish
    await tester.pumpAndSettle();

    // Navigate to category screen using bottom navigation bar
    await tester.tap(find.text('カテゴリ'));
    await tester.pumpAndSettle();

    // Verify initial category sections exist
    expect(find.text('収入カテゴリ'), findsOneWidget);
    expect(find.text('支出カテゴリ'), findsOneWidget);

    // Add new income category
    await tester.tap(find.text('カテゴリの追加'));
    await tester.pumpAndSettle();

    // Select income category type (already selected by default)
    await tester.enterText(find.widgetWithText(TextField, 'カテゴリ名'), '給料');
    await tester.tap(find.text('登録'));
    await tester.pumpAndSettle();

    // Add new expense category
    await tester.tap(find.text('カテゴリの追加'));
    await tester.pumpAndSettle();

    // Select expense category type
    await tester.tap(find.text('支出'));
    await tester.enterText(find.widgetWithText(TextField, 'カテゴリ名'), '食費');
    await tester.enterText(find.widgetWithText(TextField, '予算'), '30000');
    await tester.tap(find.text('登録'));
    await tester.pumpAndSettle();

    // Verify categories are created
    expect(find.text('給料'), findsOneWidget);
    expect(find.text('食費 (予算: ¥30,000)'), findsOneWidget);

    // Edit income category
    await tester.tap(find.widgetWithIcon(IconButton, Icons.edit).first);
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'カテゴリ名'), '月給');
    await tester.tap(find.text('登録'));
    await tester.pumpAndSettle();

    // Verify income category is updated
    expect(find.text('月給'), findsOneWidget);
    expect(find.text('給料'), findsNothing);

    // Delete expense category
    await tester.tap(find.widgetWithIcon(IconButton, Icons.delete).last);
    await tester.pumpAndSettle();

    // Verify expense category is deleted
    expect(find.text('食費 (予算: ¥30,000)'), findsNothing);
  });

  testWidgets(
    'ペアリング済みユーザーはふたりの家計簿でカテゴリを管理できるので、共有収支をカテゴリ別に整理できる',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await signUpApp(tester);

      // Wait for loading to finish
      await tester.pumpAndSettle();

      // Open the navigation menu to switch to shared account
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Switch to shared household account
      await tester.tap(find.text('ふたりの家計簿を見る'));
      await tester.pumpAndSettle();

      // Navigate to category screen using bottom navigation bar
      await tester.tap(find.text('カテゴリ'));
      await tester.pumpAndSettle();

      // Verify initial category sections exist
      expect(find.text('収入カテゴリ'), findsOneWidget);
      expect(find.text('支出カテゴリ'), findsOneWidget);

      // Add new shared income category
      await tester.tap(find.text('カテゴリの追加'));
      await tester.pumpAndSettle();

      // Select income category type (already selected by default)
      await tester.enterText(find.widgetWithText(TextField, 'カテゴリ名'), '共同収入');
      await tester.tap(find.text('登録'));
      await tester.pumpAndSettle();

      // Add new shared expense category
      await tester.tap(find.text('カテゴリの追加'));
      await tester.pumpAndSettle();

      // Select expense category type
      await tester.tap(find.text('支出'));
      await tester.enterText(find.widgetWithText(TextField, 'カテゴリ名'), '共同生活費');
      await tester.enterText(find.widgetWithText(TextField, '予算'), '50000');
      await tester.tap(find.text('登録'));
      await tester.pumpAndSettle();

      // Verify shared categories are created
      expect(find.text('共同収入'), findsOneWidget);
      expect(find.text('共同生活費 (予算: ¥50,000)'), findsOneWidget);

      // Edit shared income category
      await tester.tap(find.widgetWithIcon(IconButton, Icons.edit).first);
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'カテゴリ名'), '共同家賃収入');
      await tester.tap(find.text('登録'));
      await tester.pumpAndSettle();

      // Verify shared income category is updated
      expect(find.text('共同家賃収入'), findsOneWidget);
      expect(find.text('共同収入'), findsNothing);

      // Delete shared expense category
      await tester.tap(find.widgetWithIcon(IconButton, Icons.delete).last);
      await tester.pumpAndSettle();

      // Verify shared expense category is deleted
      expect(find.text('共同生活費 (予算: ¥50,000)'), findsNothing);
    },
    skip: true /* skip as paring feature is not implemented yet */,
  );
}
