import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/entity/expense.dart';
import 'package:household_accounts/entity/income.dart';
import 'package:household_accounts/presentation/dashboard/model/budget_graph_data.dart';
import 'package:household_accounts/presentation/dashboard/model/budget_graph_data_list.dart';
import 'package:household_accounts/presentation/dashboard/model/summary.dart';
import 'package:household_accounts/presentation/dashboard/repository/expense_repository.dart';
import 'package:household_accounts/presentation/dashboard/repository/income_repository.dart';
import 'package:household_accounts/presentation/dashboard/view_model.dart';
import 'package:household_accounts/presentation/dashboard/vo/budget_name.dart';
import 'package:household_accounts/vo/budget_amount.dart';
import 'package:household_accounts/vo/budget_spent.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([
  MockSpec<SummaryModel>(),
  MockSpec<BudgetGraphModel>(),
  MockSpec<IncomeRepository>(),
  MockSpec<ExpenseRepository>(),
])
import 'view_model_test.mocks.dart';

void main() {
  final date = DateTime(2025, 1);

  test('インスタンス化されたときModelがnullである', () {
    final viewModel = SummaryViewModel(
      summaryModel: SummaryModel(
        incomeRepository: MockIncomeRepository(),
        expenseRepository: MockExpenseRepository(),
      ),
      budgetGraphModel: BudgetGraphModel(),
    );

    expect(viewModel.income, isNull);
    expect(viewModel.expense, isNull);
    expect(viewModel.budgetGraphDataList, isNull);
    expect(viewModel.isInitialized, isFalse);
    expect(viewModel.hasError, isFalse);
  });

  group('Modelを通常通り取得できる場合', () {
    late SummaryModel summaryModel;
    late BudgetGraphModel budgetGraphModel;
    late SummaryViewModel sut;

    setUp(() {
      // mock
      summaryModel = MockSummaryModel();
      when(summaryModel.fetch(date)).thenAnswer(
        (_) async => Summary(Income(100), Expense(70)),
      );

      budgetGraphModel = MockBudgetGraphModel();
      when(budgetGraphModel.fetch(date)).thenAnswer(
        (_) async => BudgetGraphDataList([
          BudgetGraphData(
            name: BudgetName('食費'),
            budget: BudgetAmount(2000),
            spent: BudgetSpent(1000),
          ),
        ]),
      );

      // initialize ViewModel
      sut = SummaryViewModel(
        summaryModel: summaryModel,
        budgetGraphModel: budgetGraphModel,
      );
    });

    test('初期化後はModelを取得できる', () async {
      await sut.init(date);

      verify(summaryModel.fetch(date)).called(1);
      verify(budgetGraphModel.fetch(date)).called(1);
      expect(sut.income, Income(100));
      expect(sut.expense, Expense(70));
      expect(
        sut.budgetGraphDataList,
        BudgetGraphDataList([
          BudgetGraphData(
            name: BudgetName('食費'),
            budget: BudgetAmount(2000),
            spent: BudgetSpent(1000),
          ),
        ]),
      );
      expect(sut.isInitialized, isTrue);
      expect(sut.hasError, isFalse);
    });

    test('初期化時にnotifyListeners()を呼び出している', () async {
      var notifyListenersCalled = false;
      sut.addListener(() {
        notifyListenersCalled = true;
      });

      expect(notifyListenersCalled, isFalse);
      await sut.init(date);
      expect(notifyListenersCalled, isTrue);
      // notifyListeners()が呼び出されたら初期化が完了している
      expect(sut.isInitialized, isTrue);
    });
  });

  test('サマリーの取得に失敗したらエラー状態になる', () async {
    final mockSummaryModel = MockSummaryModel();
    when(mockSummaryModel.fetch(any))
        .thenThrow(SummaryModelException("テストエラー"));

    final mockBudgetGraphModel = MockBudgetGraphModel();
    when(mockBudgetGraphModel.fetch(any)).thenAnswer(
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
    await viewModel.init(date);

    verify(mockSummaryModel.fetch(date)).called(1);
    expect(viewModel.income, isNull);
    expect(viewModel.expense, isNull);
    expect(viewModel.isInitialized, isTrue);
    expect(viewModel.hasError, isTrue);
  });

  test('予算リストの取得に失敗したらエラー状態になる', () async {
    final mockSummaryModel = MockSummaryModel();
    when(mockSummaryModel.fetch(date)).thenAnswer(
      (_) async => Summary(Income(100), Expense(70)),
    );

    final mockBudgetGraphModel = MockBudgetGraphModel();
    when(mockBudgetGraphModel.fetch(date)).thenThrow(
      BudgetGraphModelException("テストエラー"),
    );
    final viewModel = SummaryViewModel(
      summaryModel: mockSummaryModel,
      budgetGraphModel: mockBudgetGraphModel,
    );
    await viewModel.init(date);

    expect(viewModel.budgetGraphDataList, isNull);
    expect(viewModel.isInitialized, isTrue);
    expect(viewModel.hasError, isTrue);
  });
}
