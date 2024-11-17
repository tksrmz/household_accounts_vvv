import 'budget.dart';
import 'expense.dart';

/// BudgetBalance used in the dashboard.
///
/// BudgetBalance is calculated by subtracting [Expense] from [Budget].
class BudgetBalance {
  /// BudgetBalance is calculated by subtracting [Expense] from [Budget].
  BudgetBalance(Budget budget, Expense expense)
      : value = budget.value - expense.value;

  /// Value of the balance of budget.
  final int value;
}
