import 'package:freezed_annotation/freezed_annotation.dart';

import 'expense.dart';
import 'income.dart';

part 'balance.freezed.dart';

/// Balance entity.
@freezed
abstract class BalanceVo with _$BalanceVo {
  const factory BalanceVo(IncomeVo income, ExpenseVo expense) = _BalanceVo;

  const BalanceVo._();

  int get value => income.value - expense.value;
}
