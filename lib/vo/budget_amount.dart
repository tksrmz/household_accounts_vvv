import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget_amount.freezed.dart';

/// 予算額
@freezed
class BudgetAmount with _$BudgetAmount {
  @Assert('value >= 0', '予算額は0以上でなければなりません')
  const factory BudgetAmount(int value) = _BudgetAmount;

  /// 予算額の合計を値に持つBudgetAmountを作成
  factory BudgetAmount.sum(List<BudgetAmount> values) {
    return BudgetAmount(values.fold(0, (sum, item) => sum + item.value));
  }
}
