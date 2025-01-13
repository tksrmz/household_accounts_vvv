import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget_spent.freezed.dart';

/// 予算の使用額
@freezed
class BudgetSpent with _$BudgetSpent {
  @Assert('value >= 0', '使用額は0以上でなければなりません')
  const factory BudgetSpent(int value) = _BudgetSpent;

  /// 使用額の合計を値に持つBudgetSpentを作成
  factory BudgetSpent.sum(List<BudgetSpent> values) {
    return BudgetSpent(values.fold(0, (sum, item) => sum + item.value));
  }

  /// メソッド追加のためにprivateコンストラクタを追加
  const BudgetSpent._();

  /// 予算を使っているか
  bool get isUsed => value > 0;

  /// 予算を使っていないか
  bool get isNotUsed => !isUsed;

  /// [value]をdoubleに変換
  double get toDouble => value.toDouble();
}
