import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/entity/expense.dart';
import 'package:household_accounts/entity/income.dart';
import 'package:household_accounts/presentation/dashboard/model/budget_graph_data_list.dart';
import 'package:household_accounts/presentation/dashboard/page.dart';
import 'package:household_accounts/presentation/dashboard/view_model.dart';
import 'package:household_accounts/presentation/dashboard/widget/budget_graph.dart';
import 'package:household_accounts/presentation/dashboard/widget/summary_panel.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<SummaryViewModel>()])
import 'page_test.mocks.dart';

void main() {
  /**
   * TODO
   *
   * - income.dartをentityディレクトリからvoディレクトリに移動する
   *   - expense.dartも？
   * - main_pageでViewModelをインスタンス化するのはいい？
   * - エラーのときはViewModelからModelを取り出せなくする
   * - ListenableBuilderを使う（どんなテストを書けばいいのかわからない…）
   * - 発生したエラーに応じてエラーメッセージの内容を変える？
   * - SummaryViewModel.init()がnotifyListeners()を呼び出している
   * - GoldenTestで見た目の調整
   * - ModelViewのテストで、ModelをisNotNullで検証するのをやめる
   * - Summaryクラスでfreezedを使う？
   * - ModelViewで2回以上init()が呼び出されても、2回目は何もしない
   * - ViewModelのincomeとexpenseを一つのプロパティ（summaryとか）にまとめる？
   * - 例外が発生したときにログを出力する？
   */
  group('SummaryPanel', () {
    testWidgets('ローディング中はローディングアイコンが表示される', (tester) async {
      final mockViewModel = MockSummaryViewModel();
      when(mockViewModel.isNotInitialized).thenReturn(true);

      await tester.pumpWidget(
        MaterialApp(
          home: DashboardPage(
            viewModel: mockViewModel,
          ),
        ),
      );

      verify(mockViewModel.init()).called(1);
      verify(mockViewModel.isNotInitialized).called(1);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('ローディング後はダッシュボードコンテンツが表示される', (tester) async {
      final mockViewModel = MockSummaryViewModel();
      when(mockViewModel.isNotInitialized).thenReturn(false);
      when(mockViewModel.income).thenReturn(Income(100));
      when(mockViewModel.expense).thenReturn(Expense(70));
      when(mockViewModel.budgetGraphDataList).thenReturn(
        BudgetGraphDataList([]),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: DashboardPage(
            viewModel: mockViewModel,
          ),
        ),
      );

      verify(mockViewModel.init()).called(1);
      verify(mockViewModel.isNotInitialized).called(1);
      expect(find.byType(SummaryPanel), findsOneWidget);
      expect(find.byType(BudgetGraph), findsOneWidget);
    });

    testWidgets('エラー発生時はエラーメッセージが表示される', (tester) async {
      final mockViewModel = MockSummaryViewModel();
      when(mockViewModel.isNotInitialized).thenReturn(false);
      when(mockViewModel.hasError).thenReturn(true);
      when(mockViewModel.errorMessage).thenReturn(
        'エラーが発生しました。時間をおいて再度お試しください。',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: DashboardPage(
            viewModel: mockViewModel,
          ),
        ),
      );

      verify(mockViewModel.init()).called(1);
      verify(mockViewModel.isNotInitialized).called(1);
      verify(mockViewModel.hasError).called(1);
      expect(find.text('エラーが発生しました。時間をおいて再度お試しください。'), findsOneWidget);
    });
  });
}
