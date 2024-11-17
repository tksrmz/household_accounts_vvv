import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget.freezed.dart';

/// Budget used in the dashboard.
@freezed
class Budget with _$Budget {
  /// Default constructor.
  ///
  /// [value] must be greater than or equal to 0.
  @Assert('value >= 0', 'Budget value cannot be negative')
  const factory Budget(int value) = _Budget;
}
