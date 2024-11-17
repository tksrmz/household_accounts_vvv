import 'expense.dart';
import 'expense_category.dart';

/// BudgetBalance used in the dashboard.
///
/// BudgetBalance is calculated by subtracting [Expense] from [ExpenseCategory].
class BudgetBalance {
  /// BudgetBalance is calculated by subtracting [Expense] from [ExpenseCategory].
  BudgetBalance(ExpenseCategory category, Expense expense)
      : value = category.budget - expense.value;

  /// Value of the balance of budget.
  final int value;
}
