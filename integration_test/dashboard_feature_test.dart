import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/main.dart';

import 'util/seed_record_dates.dart';
import 'util/sign_in.dart';

Future<void> dashboardFeature() async {
  testWidgets('ユーザーは自分の家計簿の情報をダッシュボード画面で確認できるので、家計の全体像を把握できる', (tester) async {
    // seedレコードの日付を実行時の「今月」へ揃える
    // (ダッシュボードは端末ローカルTZの暦月で集計するため。詳細はヘルパーのdoc参照)
    await alignSeedRecordDatesToCurrentMonth();

    await tester.pumpWidget(const MyApp());
    await signInApp(tester, singleUser);

    // Wait for loading to finish.
    // The number of pumps will not be checked as it does not matter that how long it takes
    await tester.pumpAndSettle();

    // Check user name
    expect(find.text("Hogeの自分の家計簿"), findsOneWidget);

    // Check summary
    expect(find.text("収入"), findsOneWidget);
    expect(find.text("¥2"), findsOneWidget);
    expect(find.text("支出"), findsOneWidget);
    expect(find.text("¥3"), findsOneWidget);
    expect(find.text("残高"), findsOneWidget);
    expect(find.text("-¥1"), findsOneWidget);
    // out of scope for this sprint
    // expect(find.byType(BudgetGraph), findsOneWidget);
  });

  testWidgets('新規ユーザーは自分の家計簿の情報をダッシュボード画面で確認できるので、初期状態を把握できる', (tester) async {
    await tester.pumpWidget(const MyApp());
    await signInApp(tester, newUser);

    // Wait for loading to finish.
    // The number of pumps will not be checked as it does not matter that how long it takes
    await tester.pumpAndSettle();

    // Check summary
    expect(find.text("収入"), findsOneWidget);
    expect(find.text("支出"), findsOneWidget);
    expect(find.text("残高"), findsOneWidget);
    expect(find.text("¥0"), findsNWidgets(3)); // 収入、支出、残高で3回
    // out of scope for this sprint
    // expect(find.byType(BudgetGraph), findsOneWidget);
  });

  testWidgets('ペアリング済みユーザーはふたりの家計簿の情報をダッシュボード画面で確認できるので、共有家計の全体像を把握できる', (
    tester,
  ) async {
    // 共有ノートのseedレコードも同様に「今月」へ揃える(冪等なので再実行してよい)
    await alignSeedRecordDatesToCurrentMonth();

    await tester.pumpWidget(const MyApp());
    await signInApp(tester, pairUser);

    // Wait for loading to finish and the dashboard to be displayed
    await tester.pumpAndSettle();
    // Check user name
    expect(find.text("Piyoの自分の家計簿"), findsOneWidget);

    // Open the navigation menu
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    expect(find.text("自分の家計簿"), findsOneWidget);

    // Change to pair mode
    await tester.tap(find.text("ふたりの家計簿を見る"));
    await tester.pumpAndSettle();

    // Check user name
    expect(find.text("Piyoのふたりの家計簿"), findsOneWidget);

    // Check summary
    expect(find.text("収入"), findsOneWidget);
    expect(find.text("¥20"), findsOneWidget);
    expect(find.text("支出"), findsOneWidget);
    expect(find.text("¥9"), findsOneWidget);
    expect(find.text("残高"), findsOneWidget);
    expect(find.text("¥11"), findsOneWidget);
  });
}
