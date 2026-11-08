import 'package:freezed_annotation/freezed_annotation.dart';

import 'category.dart';
import 'category_id.dart';
import 'category_spending.dart';
import 'record.dart';

part 'budget_summary.freezed.dart';

/// 期間中の支出カテゴリごとの予算の消化状況。
@freezed
abstract class BudgetSummary with _$BudgetSummary {
  const factory BudgetSummary({
    /// 支出カテゴリごとの支出額。渡されたカテゴリの並びを保ち、支出の無い
    /// カテゴリも支出額0として含む。
    required List<CategorySpending> categories,

    /// どの支出カテゴリにも一致しない支出の合計(0以上)。
    ///
    /// カテゴリの削除は参照する記録の有無を確かめずに行うため、削除された
    /// カテゴリを参照する支出が残りうる。それらを捨てると期間中の支出の合計が
    /// 実際より少なく見えてしまうため、まとめてここに持つ。
    required int orphanedExpense,
  }) = _BudgetSummary;

  /// [records]の支出を[categories]ごとに合算する。
  ///
  /// 収入と振替は予算の消化に関係しないため集計に含めない。期間による
  /// 絞り込みは行わないため、集計したい期間のレコードだけを渡すこと。
  factory BudgetSummary.from(
    List<ExpenseCategory> categories,
    List<Record> records,
  ) {
    final spentByCategory = <CategoryId, int>{};
    for (final record in records) {
      if (record case ExpenseRecord(:final categoryId, :final amount)) {
        spentByCategory[categoryId] =
            (spentByCategory[categoryId] ?? 0) + amount.value;
      }
    }

    final categoryIds = categories.map((category) => category.id).toSet();
    var orphanedExpense = 0;
    for (final MapEntry(:key, :value) in spentByCategory.entries) {
      if (!categoryIds.contains(key)) {
        orphanedExpense += value;
      }
    }

    return BudgetSummary(
      categories: [
        for (final category in categories)
          (category: category, spent: spentByCategory[category.id] ?? 0),
      ],
      orphanedExpense: orphanedExpense,
    );
  }
}
