import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/presentation/dashboard/widget/budget_graph.dart';

void main() {
  /**
   * TODO
   * - Figmaと同じように表示される
   *   - データがないとき
   *   - データが1つのとき
   *     - 残高が0のとき
   *     - 残高が正のとき
   *     - 残高が負のとき
   *   - データが2つのとき
   *     - 残高が0のとき
   *     - 残高が正のとき
   *     - 残高が負のとき
   *   - データが3つのとき
   *     - 残高が0のとき
   *     - 残高が正のとき
   *     - 残高が負のとき
   *   - データが4つ以上のとき
   *     - 残高が0のとき
   *     - 残高が正のとき
   *     - 残高が負のとき
   * - Figmaと同じように表示されるかをチェックするとき、データの個数ごとに残高をテストする必要があるか？
   * - 1番割合の高い予算は赤色、2番めは青色、3番めは黄色、その他は水色で表示される
   *   - 未使用額の部分は黒で塗りつぶされる
   * - BudgetGraphDataを別のファイルに切り出す
   * - BudgetGraphDataのプロパティでVOを使う
   * - 予算の名前が0文字のときはどうする？
   * - 予算の名前が上限（何文字？）を超えたときはどうする？
   * - 予算や使用額の文字数が多すぎるときはどう表示する？
   *   - 6桁の額(数十万円)をテストする
   * - 実装側にコメントを追加する
   * - デザインが決まったらExpandedやFlexibleを削除できないか検討する
   * - フォントやサイズの設定が正しいかをテストする
   * - BudgetGraphData.spent, .budgetに負の値が渡されたらどうする？
   * - _TextAtCenterOfGraphにExpandedではなくFlexibleを使う？
   */

  group('two budgets', () {
    late Widget target;

    setUp(() {
      const List budgetData = <({String name, int spent, int budget})>[
        (name: '食費', spent: 1000, budget: 2000),
        (name: '交通費', spent: 30000, budget: 40000),
      ];

      target = MaterialApp(
        home: BudgetGraph(
          list: BudgetGraphDataList(
            data: budgetData
                .map(
                  (e) => BudgetGraphData(
                    name: e.name,
                    spent: e.spent,
                    budget: e.budget,
                  ),
                )
                .toList(),
          ),
        ),
      );
    });

    testWidgets('displays info of each budget', (tester) async {
      await tester.pumpWidget(target);

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
      await tester.pumpWidget(target);

      expect(find.text('合計予算'), findsOneWidget);
      expect(find.text('¥42,000'), findsOneWidget);
    });

    testWidgets('displays balance of total budgets', (tester) async {
      await tester.pumpWidget(target);

      expect(find.text('残高'), findsOneWidget);
      expect(find.text('¥11,000'), findsOneWidget);
    });

    testWidgets('displays title of graph', (tester) async {
      await tester.pumpWidget(target);

      expect(find.text('予算'), findsOneWidget);
    });
  });
}
