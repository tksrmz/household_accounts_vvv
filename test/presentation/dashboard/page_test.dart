import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/presentation/dashboard/page.dart';

void main() {
  /**
   * TODO
   *
   * - エラーが起きたときはエラーメッセージが表示される
   * - SummaryPanelが表示される
   * - BudgetGraphが表示される
   * - ViewModelの実装を別ファイルに分ける
   * - Modelの実装を別ファイルに分ける
   * - income.dartをentityディレクトリからvoディレクトリに移動する
   *   - expense.dartも？
   * - MockitoでViewModelをモックする
   * - main_pageでViewModelをインスタンス化するのはいい？
   */
  testWidgets('ローディング中はローディングアイコンが表示される', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DashboardPage(
          viewModel: SummaryViewModel(),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
