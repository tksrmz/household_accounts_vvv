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
   * - 予算の使用額が表示される
   * - 予算の合計が表示される
   * - 予算の残高が表示される
   * - 予算の合計に対する、予算の使用額の割合が表示される
   * - Figmaと同じように表示されるかをチェックするとき、データの個数ごとに残高をテストする必要があるか？
   * - 1番割合の高い予算は赤色、2番めは青色、3番めは黄色、その他は水色で表示される
   *   - 未使用額の部分は黒で塗りつぶされる
   * - BudgetGraphDataを別のファイルに切り出す
   * - BudgetGraphDataのプロパティでVOを使う
   */

  testWidgets('displays names of budgets', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BudgetGraph(
          data: [
            BudgetGraphData(
              name: '食費',
              spent: 10000,
              budget: 20000,
            ),
            BudgetGraphData(
              name: '交通費',
              spent: 30000,
              budget: 40000,
            ),
          ],
        ),
      ),
    );

    expect(find.text('食費'), findsOneWidget);
    expect(find.text('交通費'), findsOneWidget);
  });
}
