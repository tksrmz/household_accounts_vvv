import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/entity/expense.dart';
import 'package:household_accounts/entity/income.dart';
import 'package:household_accounts/presentation/dashboard/page.dart';
import 'package:household_accounts/presentation/dashboard/widget/summary_panel.dart';

void main() {
  /**
   * TODO
   *
   * - エラーが起きたときはエラーメッセージが表示される
   * - SummaryPanelが表示される
   * - BudgetGraphが表示される
   * - ViewModelの実装を別ファイルに分ける
   *   - テストも分割する
   * - Modelの実装を別ファイルに分ける
   * - income.dartをentityディレクトリからvoディレクトリに移動する
   *   - expense.dartも？
   * - MockitoでViewModelをモックする
   * - main_pageでViewModelをインスタンス化するのはいい？
   * - SummaryViewModel.init()が呼び出されたことを検証する
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

  testWidgets('SummaryPanelが表示される', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DashboardPage(
          viewModel: SummaryViewModel(),
        ),
      ),
    );

    expect(find.byType(SummaryPanel), findsOneWidget);
  });

  group('SummaryViewModel', () {
    test('インスタンス化されたときincomeとexpenseがnullである', () {
      final viewModel = SummaryViewModel();

      expect(viewModel.income, isNull);
      expect(viewModel.expense, isNull);
    });

    test('初期化後、incomeとexpenseが両方nullならローディング中', () async {
      final viewModel = SummaryViewModel();
      await viewModel.init();

      expect(viewModel.income, isNull);
      expect(viewModel.expense, isNull);
      expect(viewModel.isLoading, isTrue);
      expect(viewModel.hasError, isFalse);
    });

    test('初期化後、incomeだけがnullならエラー', () async {
      final viewModel = SummaryViewModelMock1();
      await viewModel.init();

      expect(viewModel.income, isNull);
      expect(viewModel.expense, isNotNull);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.hasError, isTrue);
    });

    test('初期化後、expenseだけがnullならエラー', () async {
      final viewModel = SummaryViewModelMock2();
      await viewModel.init();

      expect(viewModel.income, isNotNull);
      expect(viewModel.expense, isNull);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.hasError, isTrue);
    });
  });
}

class SummaryViewModelMock1 extends SummaryViewModel {
  @override
  Future<void> init() async {
    expense = Expense(100);
  }
}

class SummaryViewModelMock2 extends SummaryViewModel {
  @override
  Future<void> init() async {
    income = Income(100);
  }
}
