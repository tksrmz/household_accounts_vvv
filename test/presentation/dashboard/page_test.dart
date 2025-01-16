import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/entity/expense.dart';
import 'package:household_accounts/entity/income.dart';
import 'package:household_accounts/presentation/dashboard/page.dart';
import 'package:household_accounts/presentation/dashboard/widget/summary_panel.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<SummaryViewModel>()])
import 'page_test.mocks.dart';

void main() {
  /**
   * TODO
   *
   * - エラーが起きたときはエラーメッセージが表示される
   * - BudgetGraphが表示される
   * - ViewModelの実装を別ファイルに分ける
   *   - テストも分割する
   * - Modelの実装を別ファイルに分ける
   * - income.dartをentityディレクトリからvoディレクトリに移動する
   *   - expense.dartも？
   * - MockitoでViewModelをモックする
   * - main_pageでViewModelをインスタンス化するのはいい？
   * - SummaryViewModel.init()が呼び出されたことを検証する
   * - SummaryViewModelMock1, 2を消す
   *   - ViewModelのテストでそれ自身のMockを使っているのはおかしい
   */
  group('SummaryPanel', () {
    <(String, void Function(MockSummaryViewModel), Type)>[
      (
        'ローディング中はローディングアイコンが表示される',
        (mock) {
          when(mock.isLoading).thenReturn(true);
        },
        CircularProgressIndicator
      ),
      (
        'ローディング後はSummaryPanelが表示される',
        (mock) {
          when(mock.isLoading).thenReturn(false);
          when(mock.income).thenReturn(Income(100));
          when(mock.expense).thenReturn(Expense(200));
        },
        SummaryPanel
      )
    ].forEach((fixture) {
      final (title, setup, expected) = fixture;

      testWidgets(title, (tester) async {
        final mockViewModel = MockSummaryViewModel();
        setup(mockViewModel);

        await tester.pumpWidget(
          MaterialApp(
            home: DashboardPage(
              viewModel: mockViewModel,
            ),
          ),
        );

        verify(mockViewModel.init()).called(1);
        verify(mockViewModel.isLoading).called(1);
        expect(find.byType(expected), findsOneWidget);
      });
    });
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

  group('SummaryModel', () {
    test('TODO', () {});
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
