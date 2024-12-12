import 'package:household_accounts/feature/dashboard/entity/expense_total.dart';
import 'package:household_accounts/feature/dashboard/entity/income_total.dart';
import 'package:household_accounts/feature/dashboard/vo/financial_overview.dart';
import 'package:test/test.dart';

void main() {
  group('balance', () {
    [
      (IncomeTotal(100), ExpenseTotal(99), 1),
      (IncomeTotal(100), ExpenseTotal(100), 0),
      (IncomeTotal(100), ExpenseTotal(101), -1),
    ].forEach((element) {
      final (income, expense, expected) = element;
      test(
          'returns ${expected} when income is ${income.value} and expense is ${expense.value}',
          () {
        final actual = FinancialOverview(income, expense);
        expect(actual.balance, expected);
      });
    });
  });
}
