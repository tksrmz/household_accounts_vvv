import 'package:household_accounts/feature/dashboard/entity/expense_category.dart';

/// Sun of the budgets in each expense categories.
class BudgetTotal {
  /// Sum of the budgets in each expense categories.
  BudgetTotal(Iterable<ExpenseCategory> categories)
      : value = categories
            .map((e) => e.budget)
            .fold(0, (previousValue, element) => previousValue + element);

  /// Value of the total budget.
  final int value;
}
