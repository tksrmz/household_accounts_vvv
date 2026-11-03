import 'package:freezed_annotation/freezed_annotation.dart';

import 'record.dart';

part 'daily_summary.freezed.dart';

/// 1日分の収入/支出/振替の合計。
///
/// 収支([RecordSummary])とは異なり振替も合計に含める。月次カレンダーの日セルは
/// 資産間の付け替えも含めて「その日に何が起きたか」を示すため、収支に影響しない
/// 振替も独立した1行として表示する。
@freezed
abstract class DailySummary with _$DailySummary {
  const DailySummary._();

  const factory DailySummary({
    required int income,
    required int expense,
    required int transfer,
  }) = _DailySummary;

  /// [records]を日(1〜31)ごとに畳み込む。
  ///
  /// レコードが1件もない日はキーを持たない(ゼロ埋めした空セルを描くかどうかは
  /// 表示側の関心であり、集計結果とは分けている)。
  ///
  /// 日付の月・年は見ないため、暦月1か月分など単一の月に属するレコードを
  /// 渡すこと。複数の月をまたぐレコードを渡すと同じ日番号が合算される。
  static Map<int, DailySummary> byDay(List<Record> records) {
    final summaries = <int, DailySummary>{};
    for (final record in records) {
      final day = record.date.value.day;
      final current =
          summaries[day] ??
          const DailySummary(income: 0, expense: 0, transfer: 0);
      summaries[day] = switch (record) {
        IncomeRecord(:final amount) => current.copyWith(
          income: current.income + amount.value,
        ),
        ExpenseRecord(:final amount) => current.copyWith(
          expense: current.expense + amount.value,
        ),
        TransferRecord(:final amount) => current.copyWith(
          transfer: current.transfer + amount.value,
        ),
      };
    }
    return summaries;
  }
}
