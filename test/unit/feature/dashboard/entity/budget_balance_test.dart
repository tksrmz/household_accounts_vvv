import 'package:household_accounts/feature/dashboard/entity/budget_balance.dart';
import 'package:household_accounts/feature/dashboard/entity/expense_category.dart';
import 'package:household_accounts/feature/dashboard/entity/expense_total.dart';
import 'package:test/test.dart';

void main() {
  group('Constructor', () {
    [
      (ExpenseCategory('test', 100), ExpenseTotal(99), 1),
      (ExpenseCategory('test', 100), ExpenseTotal(100), 0),
      (ExpenseCategory('test', 100), ExpenseTotal(101), -1),
    ].forEach((element) {
      final (category, expense, expected) = element;
      test(
          'returns normally with budget of ${category.budget} and expense of ${expense.value}',
          () {
        final actual = BudgetBalance(category, expense);
        expect(actual.value, expected);
      });
    });
  });
}
