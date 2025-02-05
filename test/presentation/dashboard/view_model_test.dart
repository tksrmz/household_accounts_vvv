import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/entity/expense.dart';
import 'package:household_accounts/entity/income.dart';
import 'package:household_accounts/presentation/dashboard/model/budget_graph_data.dart';
import 'package:household_accounts/presentation/dashboard/model/budget_graph_data_list.dart';
import 'package:household_accounts/presentation/dashboard/model/summary.dart';
import 'package:household_accounts/presentation/dashboard/view_model.dart';
import 'package:household_accounts/presentation/dashboard/vo/budget_name.dart';
import 'package:household_accounts/vo/budget_amount.dart';
import 'package:household_accounts/vo/budget_spent.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<SummaryModel>(), MockSpec<BudgetGraphModel>()])
import 'view_model_test.mocks.dart';

void main() {
  test('インスタンス化されたときModelがnullである', () {
    final viewModel = SummaryViewModel(
      summaryModel: SummaryModel(),
      budgetGraphModel: BudgetGraphModel(),
    );

    expect(viewModel.income, isNull);
    expect(viewModel.expense, isNull);
    expect(viewModel.budgetGraphDataList, isNull);
    expect(viewModel.isInitialized, isFalse);
    expect(viewModel.hasError, isFalse);
  });

  test('初期化後はModelを取得できる', () async {
    final mockSummaryModel = MockSummaryModel();
    when(mockSummaryModel.fetch()).thenAnswer(
      (_) async => Summary(Income(100), Expense(70)),
    );

    final mockBudgetGraphModel = MockBudgetGraphModel();
    when(mockBudgetGraphModel.fetch()).thenAnswer(
      (_) async => BudgetGraphDataList([
        BudgetGraphData(
          name: BudgetName('食費'),
          budget: BudgetAmount(2000),
          spent: BudgetSpent(1000),
        ),
      ]),
    );

    final viewModel = SummaryViewModel(
      summaryModel: mockSummaryModel,
      budgetGraphModel: mockBudgetGraphModel,
    );
    await viewModel.init();

    verify(mockSummaryModel.fetch()).called(1);
    verify(mockBudgetGraphModel.fetch()).called(1);
    expect(viewModel.income, Income(100));
    expect(viewModel.expense, Expense(70));
    expect(
      viewModel.budgetGraphDataList,
      BudgetGraphDataList([
        BudgetGraphData(
          name: BudgetName('食費'),
          budget: BudgetAmount(2000),
          spent: BudgetSpent(1000),
        ),
      ]),
    );
    expect(viewModel.isInitialized, isTrue);
    expect(viewModel.hasError, isFalse);
  });

  test('サマリーの取得に失敗したらエラー状態になる', () async {
    final mockSummaryModel = MockSummaryModel();
    when(mockSummaryModel.fetch()).thenThrow(SummaryModelException("テストエラー"));

    // TODO BudgetGraphModel.fetchが実装されたらモックを外す
    final mockBudgetGraphModel = MockBudgetGraphModel();
    when(mockBudgetGraphModel.fetch()).thenAnswer(
      (_) async => BudgetGraphDataList([
        BudgetGraphData(
          name: BudgetName('食費'),
          budget: BudgetAmount(2000),
          spent: BudgetSpent(1000),
        ),
      ]),
    );

    final viewModel = SummaryViewModel(
      summaryModel: mockSummaryModel,
      budgetGraphModel: mockBudgetGraphModel,
    );
    await viewModel.init();

    verify(mockSummaryModel.fetch()).called(1);
    expect(viewModel.income, isNull);
    expect(viewModel.expense, isNull);
    expect(viewModel.isInitialized, isTrue);
    expect(viewModel.hasError, isTrue);
  });

  test('予算リストの取得に失敗したらエラー状態になる', () async {
    // TODO SummaryModel.fetchが実装されたらモックを外す
    final mockSummaryModel = MockSummaryModel();
    when(mockSummaryModel.fetch()).thenAnswer(
      (_) async => Summary(Income(100), Expense(70)),
    );

    final mockBudgetGraphModel = MockBudgetGraphModel();
    when(mockBudgetGraphModel.fetch()).thenThrow(
      BudgetGraphModelException("テストエラー"),
    );
    final viewModel = SummaryViewModel(
      summaryModel: mockSummaryModel,
      budgetGraphModel: mockBudgetGraphModel,
    );
    await viewModel.init();

    expect(viewModel.budgetGraphDataList, isNull);
    expect(viewModel.isInitialized, isTrue);
    expect(viewModel.hasError, isTrue);
  });
}
