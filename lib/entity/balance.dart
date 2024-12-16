import 'package:freezed_annotation/freezed_annotation.dart';

import 'expense.dart';
import 'income.dart';

part 'balance.freezed.dart';

@freezed
class Balance with _$Balance {
  /// Balance entity.
  ///
  /// [value] must be positive.
  ///
  /// This constructor should be used only when the value is already verified.
  const factory Balance(Income income, Expense expense) = _Balance;

  const Balance._();

  int get value => income.value - expense.value;
}
