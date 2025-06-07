import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget_amount.freezed.dart';

/// 予算額
@freezed
abstract class BudgetAmountVo with _$BudgetAmountVo {
  @Assert('value >= 0', '予算額は0以上でなければなりません')
  const factory BudgetAmountVo(int value) = _BudgetAmountVo;

  /// 予算額の合計を値に持つBudgetAmountVoを作成
  factory BudgetAmountVo.sum(List<BudgetAmountVo> values) {
    return BudgetAmountVo(values.fold(0, (sum, item) => sum + item.value));
  }

  /// メソッド追加のためにprivateコンストラクタを追加
  const BudgetAmountVo._();
}