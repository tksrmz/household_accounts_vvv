import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget_spent.freezed.dart';

/// 予算の使用額
@freezed
abstract class BudgetSpentVo with _$BudgetSpentVo {
  @Assert('value >= 0', '使用額は0以上でなければなりません')
  const factory BudgetSpentVo(int value) = _BudgetSpentVo;

  /// 使用額の合計を値に持つBudgetSpentVoを作成
  factory BudgetSpentVo.sum(List<BudgetSpentVo> values) {
    return BudgetSpentVo(values.fold(0, (sum, item) => sum + item.value));
  }

  /// メソッド追加のためにprivateコンストラクタを追加
  const BudgetSpentVo._();

  /// 予算を使っているか
  bool get isUsed => value > 0;

  /// 予算を使っていないか
  bool get isNotUsed => !isUsed;

  /// [value]をdoubleに変換
  double get toDouble => value.toDouble();
}