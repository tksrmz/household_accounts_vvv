import 'budget_total.dart';
import 'expense_total.dart';
import 'income_total.dart';

/// Balance used in the dashboard.
///
/// Balance is calculated by subtracting [ExpenseTotal] from [IncomeTotal].
class Balance {
  /// Calculates balance by subtracting [ExpenseTotal] from [IncomeTotal].
  Balance.income(IncomeTotal income, ExpenseTotal expense)
      : value = income.value - expense.value;

  /// Calculates balance by subtracting [ExpenseTotal] from [BudgetTotal].
  Balance.budget(BudgetTotal budget, ExpenseTotal expense)
      : value = budget.value - expense.value;

  /// Value of the balance.
  final int value;
}
