import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense_category.freezed.dart';

/// Contains expense category name and value of the budget used in the dashboard.
@freezed
class ExpenseCategory with _$ExpenseCategory {
  /// Default constructor.
  ///
  /// [budget] must be greater than or equal to 0.
  @Assert('name.length > 0', 'Name cannot be empty')
  @Assert('name.length <= ExpenseCategory.maxNameLength', 'Name is too long')
  @Assert('budget >= 0', 'Budget value cannot be negative')
  const factory ExpenseCategory(String name, int budget) = _ExpenseCategory;

  /// Maximum characters in the name of a category.
  static const int maxNameLength = 20;
}
