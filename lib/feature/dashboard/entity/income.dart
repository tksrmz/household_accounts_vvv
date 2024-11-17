import 'package:freezed_annotation/freezed_annotation.dart';

part 'income.freezed.dart';

/// Income used in the dashboard.
@freezed
class Income with _$Income {
  /// Default constructor.
  ///
  /// [value] must be greater than or equal to 0.
  @Assert('value >= 0', 'Income value cannot be negative')
  const factory Income(int value) = _Income;
}
