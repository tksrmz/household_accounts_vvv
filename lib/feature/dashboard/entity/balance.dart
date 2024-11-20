import 'expense_total.dart';
import 'income_total.dart';

/// Balance used in the dashboard.
///
/// Balance is calculated by subtracting [ExpenseTotal] from [IncomeTotal].
class Balance {
  /// Balance is calculated by subtracting [ExpenseTotal] from [IncomeTotal].
  Balance(IncomeTotal income, ExpenseTotal expense)
      : value = income.value - expense.value;

  /// Value of the balance.
  final int value;
}
