import 'package:freezed_annotation/freezed_annotation.dart';

part 'income.freezed.dart';

@freezed
class Income with _$Income {
  /// Income entity.
  ///
  /// [value] must be positive.
  ///
  /// This constructor should be used only when the value is already verified.
  @Assert('value >= 0', 'amount is negative.')
  const factory Income(int value) = _Income;

  /// Income value used instead of null.
  static const Income empty = Income(0);
}
