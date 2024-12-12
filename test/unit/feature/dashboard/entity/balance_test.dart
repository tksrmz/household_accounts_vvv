import 'package:household_accounts/feature/dashboard/entity/balance.dart';
import 'package:household_accounts/feature/dashboard/entity/budget_total.dart';
import 'package:household_accounts/feature/dashboard/entity/expense_category.dart';
import 'package:household_accounts/feature/dashboard/entity/expense_total.dart';
import 'package:household_accounts/feature/dashboard/vo/category_name.dart';
import 'package:test/test.dart';

void main() {
  group('Constructor', () {
    final budgetTotal = BudgetTotal([
      ExpenseCategory(CategoryName('test'), 100),
    ]);
    [
      (budgetTotal, ExpenseTotal(99), 1),
      (budgetTotal, ExpenseTotal(100), 0),
      (budgetTotal, ExpenseTotal(101), -1),
    ].forEach((element) {
      final (budget, expense, expected) = element;
      test(
          'income() returns normally with budget of ${budget.value} and expense of ${expense.value}',
          () {
        final actual = Balance.budget(budget, expense);
        expect(actual.value, expected);
      });
    });
  });
}
