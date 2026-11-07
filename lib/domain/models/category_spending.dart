import 'category.dart';

/// 支出カテゴリ1件と、期間中にそのカテゴリで支出した金額の合計。
///
/// 予算の消化状況([BudgetSummary])をカテゴリごとに表す要素として使う。
/// [spent]は0以上で、予算を超えることもある。
typedef CategorySpending = ({ExpenseCategory category, int spent});
