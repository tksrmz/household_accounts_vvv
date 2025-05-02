import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense.freezed.dart';

@freezed
class Expense with _$Expense {
  /// Expense entity.
  ///
  /// [value] must be positive.
  ///
  /// This constructor should be used only when the value is already verified.
  @Assert('value >= 0', 'amount is negative.')
  const factory Expense(int value) = _Expense;

  /// Expense value used instead of null.
  static const Expense empty = Expense(0);
}
