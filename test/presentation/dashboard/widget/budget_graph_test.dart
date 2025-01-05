import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/presentation/dashboard/widget/budget_graph.dart';

import '../../../util/golden_helper.dart';

void main() {
  /**
   * TODO
   * - Figmaと同じように表示される
   *  - X 設定された予算の数が4、使用された予算の数が1のケースをテストする
   *  - 設定された予算の数が4、使用された予算の数が3のケースをテストする
   *  - 設定された予算の数が4、使用された予算の数が4のケースをテストする
   *  - 設定された予算の数が5、使用された予算の数が5のケースをテストする
   *     - 残高が0のとき
   *     - 残高が正のとき
   *     - 残高が負のとき
   * - 1番割合の高い予算は赤色、2番めは青色、3番めは黄色、その他は水色で表示される
   *   - 未使用額の部分は薄い灰色で塗りつぶされる
   * - BudgetGraphDataを別のファイルに切り出す
   * - BudgetGraphDataのプロパティでVOを使う
   * - 予算の名前が0文字のときはどうする？
   * - 予算の名前が上限（何文字？）を超えたときはどうする？
   * - 予算や使用額の文字数が多すぎるときはどう表示する？
   *   - 6桁の額(数十万円)をテストする
   * - 実装側にコメントを追加する
   * - デザインが決まったらExpandedやFlexibleを削除できないか検討する
   * - BudgetGraphData.spent, .budgetに負の値が渡されたらどうする？
   * - 予算が使用額の大きい順に並んでいること
   * - Theme.of(context).textThemeの変わりにTextTheme.of(context)を使う
   * - "合計予算"を"総予算"に変える
   * - 予算の使用割合が100%を超えているとき
   * - _toLegendDataListの返り値をUnmodifiableListViewにする
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

      final int totalBudget = 2000 + 40000;

      expect(find.text('食費'), findsOneWidget);
      expect(find.text('¥1,000'), findsOneWidget);
      final int foodRatioToTotalBudget = (1000 * 100 / totalBudget).round();
      expect(find.text('($foodRatioToTotalBudget%)'), findsOneWidget);

      expect(find.text('交通費'), findsOneWidget);
      expect(find.text('¥30,000'), findsOneWidget);
      final int transportRatioToTotalBudget =
          (30000 * 100 / totalBudget).round();
      expect(find.text('($transportRatioToTotalBudget%)'), findsOneWidget);
    });

    testWidgets('displays total budget', (tester) async {
      await tester.pumpWidget(MaterialApp(home: build()));

      expect(find.text('合計予算'), findsOneWidget);
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

      expect(find.text('合計予算'), findsOneWidget);
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
      (name: '食費', spent: 0, budget: 2000),
      (name: '交通費', spent: 0, budget: 40000),
      (name: '日用品', spent: 0, budget: 600),
      (name: '光熱費', spent: 500000, budget: 800000),
    ]),
  );
}

BudgetGraph Function() _getBuilder(
  List<({String name, int spent, int budget})> data,
) {
  return () => BudgetGraph(
        list: BudgetGraphDataList(
          data: data
              .map(
                (e) => BudgetGraphData(
                  name: e.name,
                  spent: e.spent,
                  budget: e.budget,
                ),
              )
              .toList(),
        ),
      );
}
