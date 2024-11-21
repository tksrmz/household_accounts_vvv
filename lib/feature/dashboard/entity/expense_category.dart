import 'package:freezed_annotation/freezed_annotation.dart';

import '../vo/category_name.dart';

part 'expense_category.freezed.dart';

/// Contains expense category name and value of the budget used in the dashboard.
@freezed
class ExpenseCategory with _$ExpenseCategory {
  /// Default constructor.
  ///
  /// [budget] must be greater than or equal to 0.
  @Assert('budget >= 0', 'Budget value cannot be negative')
  const factory ExpenseCategory(CategoryName name, int budget) =
      _ExpenseCategory;
}
