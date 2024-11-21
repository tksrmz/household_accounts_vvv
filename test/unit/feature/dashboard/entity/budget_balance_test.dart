import 'package:household_accounts/feature/dashboard/entity/budget_balance.dart';
import 'package:household_accounts/feature/dashboard/entity/expense_category.dart';
import 'package:household_accounts/feature/dashboard/entity/expense_total.dart';
import 'package:household_accounts/feature/dashboard/vo/category_name.dart';
import 'package:test/test.dart';

void main() {
  group('Constructor', () {
    final category = ExpenseCategory(CategoryName('test'), 100);
    [
      (category, ExpenseTotal(99), 1),
      (category, ExpenseTotal(100), 0),
      (category, ExpenseTotal(101), -1),
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
