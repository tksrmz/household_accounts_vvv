import 'package:household_accounts/feature/dashboard/entity/budget.dart';
import 'package:household_accounts/feature/dashboard/entity/budget_balance.dart';
import 'package:household_accounts/feature/dashboard/entity/expense.dart';
import 'package:test/test.dart';

void main() {
  group('Constructor', () {
    [
      (Budget(100), Expense(99), 1),
      (Budget(100), Expense(100), 0),
      (Budget(100), Expense(101), -1),
    ].forEach((element) {
      final (budget, expense, expected) = element;
      test(
          'returns normally with budget of ${budget.value} and expense of ${expense.value}',
          () {
        final actual = BudgetBalance(budget, expense);
        expect(actual.value, expected);
      });
    });
  });
}
