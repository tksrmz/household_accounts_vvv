import 'package:household_accounts/feature/dashboard/entity/balance.dart';
import 'package:household_accounts/feature/dashboard/entity/expense_total.dart';
import 'package:household_accounts/feature/dashboard/entity/income_total.dart';
import 'package:test/test.dart';

void main() {
  group('Constructor', () {
    [
      (IncomeTotal(100), ExpenseTotal(99), 1),
      (IncomeTotal(100), ExpenseTotal(100), 0),
      (IncomeTotal(100), ExpenseTotal(101), -1),
    ].forEach((element) {
      final (income, expense, expected) = element;
      test(
          'returns normally with income of ${income.value} and expense of ${expense.value}',
          () {
        final actual = Balance(income, expense);
        expect(actual.value, expected);
      });
    });
  });
}
