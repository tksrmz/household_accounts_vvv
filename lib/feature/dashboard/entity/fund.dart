import 'package:freezed_annotation/freezed_annotation.dart';

part 'fund.freezed.dart';

/// Contains fund name and its amount used in the dashboard.
@freezed
class Fund with _$Fund {
  /// Default constructor.
  ///
  /// [budget] must be greater than or equal to 0.
  ///
  /// [name] must be greater than 0 characters and less than or equal to [maxNameLength].
  @Assert('name.length > 0', 'Name cannot be empty')
  @Assert('name.length <= Fund.maxNameLength', 'Name is too long')
  @Assert('budget >= 0', 'Budget value cannot be negative')
  const factory Fund(String name, int budget) = _Fund;

  /// Maximum characters in the name of a category.
  static const int maxNameLength = 20;
}
