import 'package:freezed_annotation/freezed_annotation.dart';

import 'vo/budget_amount.dart';
import 'vo/category_id.dart';
import 'vo/category_name.dart';

part 'expense_category.freezed.dart';

/// 支出カテゴリ
@freezed
abstract class ExpenseCategoryModel with _$ExpenseCategoryModel {
  const factory ExpenseCategoryModel({
    required CategoryIdVo id,
    required CategoryNameVo name,
    required BudgetAmountVo totalBudget,
  }) = _ExpenseCategoryModel;

  const ExpenseCategoryModel._();

  /// 削除済みカテゴリ
  static const deleted = ExpenseCategoryModel(
    id: CategoryIdVo('deleted-expense-category'),
    name: CategoryNameVo('削除済み'),
    totalBudget: BudgetAmountVo(0),
  );
}
