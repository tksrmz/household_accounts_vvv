import 'package:freezed_annotation/freezed_annotation.dart';

import 'budget.dart';
import 'category_id.dart';
import 'category_name.dart';

part 'category.freezed.dart';

/// 収入カテゴリ。
@freezed
abstract class IncomeCategory with _$IncomeCategory {
  const factory IncomeCategory({
    required CategoryId id,
    required CategoryName name,
  }) = _IncomeCategory;
}

/// 支出カテゴリ。
///
/// 収入カテゴリと違い、カテゴリごとの予算[budget]を持つ(Firestore上の
/// フィールド名は`totalBudget`)。
@freezed
abstract class ExpenseCategory with _$ExpenseCategory {
  const factory ExpenseCategory({
    required CategoryId id,
    required CategoryName name,
    required Budget budget,
  }) = _ExpenseCategory;
}
