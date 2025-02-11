import 'package:household_accounts/presentation/dashboard/model/summary.dart';
import 'package:household_accounts/presentation/dashboard/repository/expense_repository.dart';
import 'package:household_accounts/presentation/dashboard/repository/income_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

@GenerateNiceMocks([
  MockSpec<IncomeRepository>(),
  MockSpec<ExpenseRepository>(),
])
import 'summary_test.mocks.dart';

void main() {
  test('incomeとexpenseがともに0円のとき', () async {
    final date = DateTime(2025, 1);

    final mockIncomeRepository = MockIncomeRepository();
    when(mockIncomeRepository.fetchMonthly(date)).thenAnswer((_) async => []);
    final mockExpenseRepository = MockExpenseRepository();
    when(mockExpenseRepository.fetchMonthly(date)).thenAnswer((_) async => []);

    final summary = await SummaryModel(
      incomeRepository: MockIncomeRepository(),
      expenseRepository: MockExpenseRepository(),
    ).fetch(date);

    verify(mockIncomeRepository.fetchMonthly(date)).called(1);
    verify(mockExpenseRepository.fetchMonthly(date)).called(1);
    expect(summary.income.value, 0);
    expect(summary.expense.value, 0);
  });
}
