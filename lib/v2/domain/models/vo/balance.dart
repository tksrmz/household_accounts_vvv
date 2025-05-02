import 'package:freezed_annotation/freezed_annotation.dart';

import 'expense.dart';
import 'income.dart';

part 'balance.freezed.dart';

@freezed

/// Balance entity.
class Balance with _$Balance {
  const factory Balance(Income income, Expense expense) = _Balance;

  const Balance._();

  int get value => income.value - expense.value;
}
