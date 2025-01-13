import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/presentation/dashboard/vo/budget_name.dart';
import 'package:household_accounts/presentation/dashboard/vo/budget_spent.dart';
import 'package:household_accounts/presentation/dashboard/widget/budget_graph.dart';
import 'package:household_accounts/vo/budget_amount.dart';

import '../../../util/golden_helper.dart';

void main() {
  /**
   * TODO
   * - VOのクラスが重複している場合はどちらかに統合する
   */

  /**
   * Won't
   * - 予算の名前が0文字のときのテスト
   *   - 0文字の予算名はassert（事前条件）で弾いているため、テスト不要（契約によるテスト）
   *   - 同様の理由に付き、以下のケースのテストも不要
   *     - 予算名が最大文字数を超えているとき
   *     - 予算の使用額が負のとき
   *     - 予算額が負のとき
   */

  group('予算が未設定のとき', () {
    final BudgetGraph Function() build = _getBuilder([]);

    testWidgets('displays "予算が未設定です"', (tester) async {
      await tester.pumpWidget(MaterialApp(home: build()));

      expect(find.text('予算が未設定です'), findsOneWidget);
    });

    testWidgets('displays balance and total budget as 0', (tester) async {
      await tester.pumpWidget(MaterialApp(home: build()));

      expect(find.text('¥0'), findsNWidgets(2));
    });

    testGoldens(
      '予算が未設定のとき',
      goldenFileName: 'budget_graph/budget_not_configured',
      builder: build,
    );
  });

  group('予算設定が2つあり、両方使用しているとき', () {
    final BudgetGraph Function() build = _getBuilder([
      (name: '食費', spent: 1000, budget: 2000),
      (name: '交通費', spent: 30000, budget: 40000),
    ]);

    testWidgets('displays info of each budget', (tester) async {
      await tester.pumpWidget(MaterialApp(home: build()));

      expect(find.text('食費'), findsOneWidget);
      expect(find.text('¥1,000'), findsOneWidget);

      expect(find.text('交通費'), findsOneWidget);
      expect(find.text('¥30,000'), findsOneWidget);
    });

    testWidgets('displays total budget', (tester) async {
      await tester.pumpWidget(MaterialApp(home: build()));

      expect(find.text('総予算'), findsOneWidget);
      expect(find.text('¥42,000'), findsOneWidget);
    });

    testWidgets('displays balance of total budgets', (tester) async {
      await tester.pumpWidget(MaterialApp(home: build()));

      expect(find.text('残高'), findsOneWidget);
      expect(find.text('¥11,000'), findsOneWidget);
    });

    testWidgets('displays title of graph', (tester) async {
      await tester.pumpWidget(MaterialApp(home: build()));

      expect(find.text('予算'), findsOneWidget);
    });
  });

  group('予算設定が4つあり、ひとつも使用していないとき', () {
    final BudgetGraph Function() build = _getBuilder([
      (name: '食費', spent: 0, budget: 2000),
      (name: '交通費', spent: 0, budget: 40000),
      (name: '日用品', spent: 0, budget: 600),
      (name: '光熱費', spent: 0, budget: 800000),
    ]);

    testWidgets('displays "予算を使っていません"', (tester) async {
      await tester.pumpWidget(MaterialApp(home: build()));

      expect(find.text('予算を使っていません'), findsOneWidget);
      expect(find.text('食費'), findsNothing);
      expect(find.text('交通費'), findsNothing);
      expect(find.text('日用品'), findsNothing);
      expect(find.text('光熱費'), findsNothing);
    });

    testWidgets('total budget and balance is equal', (tester) async {
      await tester.pumpWidget(MaterialApp(home: build()));

      expect(find.text('総予算'), findsOneWidget);
      expect(find.text('残高'), findsOneWidget);
      expect(find.text('¥842,600'), findsNWidgets(2));
    });

    testGoldens(
      '予算をひとつも使用していないとき',
      goldenFileName: 'budget_graph/no_budget_used',
      builder: build,
    );
  });

  testGoldens(
    '予算が4つあり、1つ使用しているとき',
    goldenFileName: 'budget_graph/4_budgets_1_used',
    builder: _getBuilder([
      (name: '食費', spent: 1, budget: 1),
      (name: '交通費', spent: 0, budget: 2),
      (name: '日用品', spent: 0, budget: 3),
      (name: '光熱費', spent: 0, budget: 5),
    ]),
  );

  testGoldens(
    '予算が4つあり、3つ使用しているとき',
    goldenFileName: 'budget_graph/4_budgets_3_used',
    builder: _getBuilder([
      (name: '食費', spent: 1000, budget: 1000),
      (name: '交通費', spent: 2000, budget: 2000),
      (name: '日用品', spent: 3000, budget: 3000),
      (name: '光熱費', spent: 0, budget: 4000),
    ]),
  );

  testGoldens(
    '予算が4つあり、4つ使用しているとき',
    goldenFileName: 'budget_graph/4_budgets_4_used',
    builder: _getBuilder([
      (name: '食費', spent: 1000, budget: 1000),
      (name: '交通費', spent: 2000, budget: 2000),
      (name: '日用品', spent: 3000, budget: 3000),
      (name: '光熱費', spent: 4000, budget: 4000),
    ]),
  );

  testGoldens(
    '予算が5つあり、5つ使用しているとき',
    goldenFileName: 'budget_graph/5_budgets_5_used',
    builder: _getBuilder([
      (name: '食費', spent: 1000, budget: 1500),
      (name: '交通費', spent: 2000, budget: 2000),
      (name: '日用品', spent: 3000, budget: 3000),
      (name: '光熱費', spent: 4000, budget: 4000),
      (name: '趣味', spent: 4001, budget: 4001),
    ]),
  );

  testGoldens(
    '残高が負のとき',
    goldenFileName: 'budget_graph/negative_balance',
    builder: _getBuilder([
      (name: '食費', spent: 2, budget: 1),
      (name: '交通費', spent: 4, budget: 3),
    ]),
  );

  testGoldens(
    '予算名や予算額の文字数が多いとき',
    goldenFileName: 'budget_graph/long_name_and_amount',
    builder: _getBuilder([
      (
        name: 'あ' * BudgetName.maxLength,
        /**
         * intは64bit
         *
         * For native targets, you can assume that int maps to a signed 64-bit
         * integer representation and double maps to a 64-bit IEEE floating-point
         * representation that matches the underlying processor.
         * https://dart.dev/resources/language/number-representation#dart-number-representation
         */
        spent: 0x7FFF_FFFF_FFFF_FFFF,
        budget: 0x7FFF_FFFF_FFFF_FFFF,
      ),
    ]),
  );
}

BudgetGraph Function() _getBuilder(
  List<({String name, int spent, int budget})> data,
) {
  return () => BudgetGraph(
        list: BudgetGraphDataList(
          data
              .map(
                (e) => BudgetGraphData(
                  name: BudgetName(e.name),
                  spent: BudgetSpent(e.spent),
                  budget: BudgetAmount(e.budget),
                ),
              )
              .toList(),
        ),
      );
}
