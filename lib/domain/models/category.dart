import 'package:freezed_annotation/freezed_annotation.dart';

import 'category_id.dart';

part 'category.freezed.dart';

/// 収入カテゴリ。
///
/// 記録入力(カテゴリ選択)が必要とする最小限のフィールドのみを持つ。
/// 名前の検証付き値型化・予算は、カテゴリ管理画面の移行時にあわせて追加する
/// (この画面の移行時点ではカテゴリを選択できれば十分なため)。
@freezed
abstract class IncomeCategory with _$IncomeCategory {
  const factory IncomeCategory({required CategoryId id, required String name}) =
      _IncomeCategory;
}

/// 支出カテゴリ。
///
/// 記録入力(カテゴリ選択)が必要とする最小限のフィールドのみを持つ。
/// 名前の検証付き値型化・予算は、カテゴリ管理画面の移行時にあわせて追加する
/// (この画面の移行時点ではカテゴリを選択できれば十分なため)。
@freezed
abstract class ExpenseCategory with _$ExpenseCategory {
  const factory ExpenseCategory({
    required CategoryId id,
    required String name,
  }) = _ExpenseCategory;
}
