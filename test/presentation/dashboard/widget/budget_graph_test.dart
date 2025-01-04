import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/presentation/dashboard/widget/budget_graph.dart';

import '../../../util/golden_helper.dart';

void main() {
  /**
   * TODO
   * - Figmaと同じように表示される
   *   - データが1つのとき
   *   - データが2つのとき
   *   - データが3つのとき
   *   - データが4つ以上のとき
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
   * - フォントや色の設定をする
   *   - "予算を使っていません"
   * - BudgetGraphData.spent, .budgetに負の値が渡されたらどうする？
   * - 予算が使用額の大きい順に並んでいること
   * - 予算が1円も使われていないときは
   *   - "予算を使っていません"と表示する
   *   - 中央には残高と合計予算が同じ額で表示される
   * - Theme.of(context).textThemeの変わりにTextTheme.of(context)を使う
   * - "合計予算"を"総予算"に変える
   */

  group('予算の設定数', () {
    group('予算が未設定のとき', () {
      late Widget target;
      setUp(() {
        target = MaterialApp(
          home: BudgetGraph(
            list: BudgetGraphDataList(
              data: [],
            ),
          ),
        );
      });

      testWidgets('displays "予算が未設定です"', (tester) async {
        await tester.pumpWidget(target);

        expect(find.text('予算が未設定です'), findsOneWidget);
      });

      testWidgets('displays balance and total budget as 0', (tester) async {
        await tester.pumpWidget(target);

        expect(find.text('¥0'), findsNWidgets(2));
      });
    });

    group('予算設定が1つのとき', () {});

    group('予算設定が2つのとき', () {
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

    group('予算設定が3つのとき', () {});

    group('予算設定が4つ以上のとき', () {});
  });

  group('予算の残高', () {
    group('予算を1円も使っていないとき', () {});

    group('予算の残高が正のとき', () {});

    group('予算の残高が0のとき', () {});

    group('予算の残高が負のとき', () {});
  });

  testGoldens(
    '予算が未設定のとき',
    goldenFileName: 'budget_graph_budget_not_configured',
    builder: () => BudgetGraph(
      list: BudgetGraphDataList(
        data: [],
      ),
    ),
  );
}
