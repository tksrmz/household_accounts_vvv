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
   * - テストをView、ViewModel、Modelごとに分割する
   * - income.dartをentityディレクトリからvoディレクトリに移動する
   *   - expense.dartも？
   * - main_pageでViewModelをインスタンス化するのはいい？
   * - SummaryViewModel.init()が呼び出されたことを検証する
   * - SummaryViewModelMock1, 2を消す
   *   - ViewModelのテストでそれ自身のMockを使っているのはおかしい
   * - エラーのときはViewModelからModelを取り出せなくする
   * - ListenableBuilderを使う
   * - 発生したエラーに応じてエラーメッセージの内容を変える？
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

  group(
    'SummaryViewModel',
    () {
      test('インスタンス化されたときModelがnullである', () {
        final viewModel = SummaryViewModel();

        expect(viewModel.income, isNull);
        expect(viewModel.expense, isNull);
        expect(viewModel.budgetGraphDataList, isNull);
        expect(viewModel.isInitialized, isFalse);
      });

      test('初期化後、Modelがすべてnullでないならローディング中ではない', () async {
        final viewModel = SummaryViewModel();
        await viewModel.init();

        expect(viewModel.income, isNotNull);
        expect(viewModel.expense, isNotNull);
        expect(viewModel.budgetGraphDataList, isNotNull);
        expect(viewModel.isInitialized, isTrue);
        expect(viewModel.hasError, isFalse);
      });

      test('初期化後、incomeがnullならエラー', () async {
        final viewModel = SummaryViewModelMock1();
        await viewModel.init();

        expect(viewModel.income, isNull);
        expect(viewModel.isInitialized, isTrue);
        expect(viewModel.hasError, isTrue);
      });

      test('初期化後、expenseがnullならエラー', () async {
        final viewModel = SummaryViewModelMock2();
        await viewModel.init();

        expect(viewModel.expense, isNull);
        expect(viewModel.isInitialized, isTrue);
        expect(viewModel.hasError, isTrue);
      });

      test('初期化後、budgetGraphDataListがnullならエラー', () async {
        final viewModel = SummaryViewModelMock3();
        await viewModel.init();

        expect(viewModel.budgetGraphDataList, isNull);
        expect(viewModel.isInitialized, isTrue);
        expect(viewModel.hasError, isTrue);
      });
    },
    skip: true,
  );

  group('SummaryModel', () {
    test('TODO', () {});
  });
}

class SummaryViewModelMock1 extends SummaryViewModel {
  @override
  Future<void> init() async {
    super.init();
    income = null;
  }
}

class SummaryViewModelMock2 extends SummaryViewModel {
  @override
  Future<void> init() async {
    super.init();
    expense = null;
  }
}

class SummaryViewModelMock3 extends SummaryViewModel {
  @override
  Future<void> init() async {
    super.init();
    budgetGraphDataList = null;
  }
}
