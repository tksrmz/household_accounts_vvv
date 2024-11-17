import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense.freezed.dart';

/// Expense used in the dashboard.
@freezed
class Expense with _$Expense {
  /// Default constructor.
  ///
  /// [value] must be greater than or equal to 0.
  @Assert('value >= 0', 'Expense value cannot be negative')
  const factory Expense(int value) = _Expense;
}
