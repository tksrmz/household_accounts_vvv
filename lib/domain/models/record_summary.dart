import 'package:freezed_annotation/freezed_annotation.dart';

import 'record.dart';

part 'record_summary.freezed.dart';

/// 期間中の収入/支出の集計。
///
/// ダッシュボードの月次集計や日次明細の合計など、期間を問わず同じ集計を
/// 使い回せるように、名前を期間中立(月次/日次を含まない)にしている。
@freezed
abstract class RecordSummary with _$RecordSummary {
  const RecordSummary._();

  const factory RecordSummary({required int income, required int expense}) =
      _RecordSummary;

  /// 収支(収入 - 支出)。負になりうる。
  int get balance => income - expense;

  /// [records]を集計して[RecordSummary]を生成する。
  ///
  /// 振替(transfer)は資産間の付け替えであり収支に影響しないため、集計に含めない。
  factory RecordSummary.from(List<Record> records) {
    var income = 0;
    var expense = 0;
    for (final record in records) {
      switch (record) {
        case IncomeRecord(:final amount):
          income += amount.value;
        case ExpenseRecord(:final amount):
          expense += amount.value;
        case TransferRecord():
          break;
      }
    }
    return RecordSummary(income: income, expense: expense);
  }
}
