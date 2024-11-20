import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense_total.freezed.dart';

/// Expense used in the dashboard.
@freezed
class ExpenseTotal with _$ExpenseTotal {
  /// Default constructor.
  ///
  /// [value] must be greater than or equal to 0.
  @Assert('value >= 0', 'Expense value cannot be negative')
  const factory ExpenseTotal(int value) = _ExpenseTotal;
}
