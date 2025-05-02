import 'package:household_accounts/entity/expense.dart';
import 'package:household_accounts/entity/income.dart';
import 'package:household_accounts/v2/domain/repositories/expense_repository.dart';
import 'package:household_accounts/v2/domain/repositories/income_repository.dart';
import 'package:household_accounts/v2/domain/usecases/summary.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

@GenerateNiceMocks([
  MockSpec<IncomeRepository>(),
  MockSpec<ExpenseRepository>(),
])
import 'summary_test.mocks.dart';

void main() {
  [
    (
      description: 'incomeとexpenseがともに0円のとき',
      incomeAnswer: <Income>[],
      expenseAnswer: <Expense>[],
      expectedIncome: 0,
      expectedExpense: 0,
    ),
    (
      description: 'incomeとexpenseがともに0円ではないとき',
      incomeAnswer: [
        Income(100),
        Income(200),
      ],
      expenseAnswer: [
        Expense(50),
        Expense(100),
      ],
      expectedIncome: 300,
      expectedExpense: 150,
    ),
  ].forEach((testData) {
    test(testData.description, () async {
      final date = DateTime(2025, 1);

      final mockIncomeRepository = MockIncomeRepository();
      when(mockIncomeRepository.fetchMonthly(date)).thenAnswer(
        (_) async => testData.incomeAnswer,
      );
      final mockExpenseRepository = MockExpenseRepository();
      when(mockExpenseRepository.fetchMonthly(date)).thenAnswer(
        (_) async => testData.expenseAnswer,
      );

      final summary = await SummaryModel(
        incomeRepository: mockIncomeRepository,
        expenseRepository: mockExpenseRepository,
      ).fetch(date);

      verify(mockIncomeRepository.fetchMonthly(date)).called(1);
      verify(mockExpenseRepository.fetchMonthly(date)).called(1);
      expect(summary.income.value, testData.expectedIncome);
      expect(summary.expense.value, testData.expectedExpense);
    });
  });

  test('IncomeRepositoryで例外が発生したとき', () async {
    final date = DateTime(2025, 1);

    final mockIncomeRepository = MockIncomeRepository();
    when(mockIncomeRepository.fetchMonthly(date)).thenThrow(
      Exception('テストエラー'),
    );
    final mockExpenseRepository = MockExpenseRepository();
    when(mockExpenseRepository.fetchMonthly(date)).thenAnswer(
      (_) async => <Expense>[],
    );

    expect(
      () async => await SummaryModel(
        incomeRepository: mockIncomeRepository,
        expenseRepository: mockExpenseRepository,
      ).fetch(date),
      throwsA(isA<SummaryModelException>()),
    );
  });

  test('ExpenseRepositoryで例外が発生したとき', () async {
    final date = DateTime(2025, 1);

    final mockIncomeRepository = MockIncomeRepository();
    when(mockIncomeRepository.fetchMonthly(date)).thenAnswer(
      (_) async => <Income>[],
    );
    final mockExpenseRepository = MockExpenseRepository();
    when(mockExpenseRepository.fetchMonthly(date)).thenThrow(
      Exception('テストエラー'),
    );

    expect(
      () async => await SummaryModel(
        incomeRepository: mockIncomeRepository,
        expenseRepository: mockExpenseRepository,
      ).fetch(date),
      throwsA(isA<SummaryModelException>()),
    );
  });
}
