import 'expense_category.dart';
import 'expense_total.dart';

/// BudgetBalance used in the dashboard.
///
/// BudgetBalance is calculated by subtracting [ExpenseTotal] from [ExpenseCategory].
class BudgetBalance {
  /// BudgetBalance is calculated by subtracting [ExpenseTotal] from [ExpenseCategory].
  BudgetBalance(ExpenseCategory category, ExpenseTotal expense)
      : value = category.budget - expense.value;

  /// Value of the balance of budget.
  final int value;
}
