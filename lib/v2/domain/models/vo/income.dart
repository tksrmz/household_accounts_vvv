import 'package:freezed_annotation/freezed_annotation.dart';

part 'income.freezed.dart';

@freezed
abstract class IncomeVo with _$IncomeVo {
  /// Income entity.
  ///
  /// [value] must be positive.
  ///
  /// This constructor should be used only when the value is already verified.
  @Assert('value >= 0', 'amount is negative.')
  const factory IncomeVo(int value) = _IncomeVo;

  /// Income value used instead of null.
  static const IncomeVo empty = IncomeVo(0);
}
