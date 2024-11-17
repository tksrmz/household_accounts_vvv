import 'expense.dart';
import 'income.dart';

/// Balance used in the dashboard.
///
/// Balance is calculated by subtracting [Expense] from [Income].
class Balance {
  /// Balance is calculated by subtracting [Expense] from [Income].
  Balance(Income income, Expense expense)
      : value = income.value - expense.value;

  /// Value of the balance.
  final int value;
}
