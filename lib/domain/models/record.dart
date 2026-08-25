import 'package:freezed_annotation/freezed_annotation.dart';

import 'amount.dart';
import 'category_id.dart';
import 'property_id.dart';
import 'record_date.dart';
import 'record_id.dart';
import 'record_note.dart';

part 'record.freezed.dart';

/// 収入/支出/振替の記録を表すsealed union。
@freezed
sealed class Record with _$Record {
  /// 収入の記録。
  const factory Record.income({
    required RecordId id,
    required RecordDate date,
    required Amount amount,
    required RecordNote note,
    required CategoryId categoryId,
    required PropertyId propertyId,
  }) = IncomeRecord;

  /// 支出の記録。
  const factory Record.expense({
    required RecordId id,
    required RecordDate date,
    required Amount amount,
    required RecordNote note,
    required CategoryId categoryId,
    required PropertyId propertyId,
  }) = ExpenseRecord;

  /// 振替の記録。
  ///
  /// [fromPropertyId]と[toPropertyId]が同一のときはビジネスルール違反であり、
  /// 呼び出し側の実装ミス(ユーザーの入力ミスではない)であるため、AssertionErrorで
  /// fail fastさせる。
  @Assert('fromPropertyId != toPropertyId', '振替元と振替先は異なる資産が必要')
  const factory Record.transfer({
    required RecordId id,
    required RecordDate date,
    required Amount amount,
    required RecordNote note,
    required PropertyId fromPropertyId,
    required PropertyId toPropertyId,
  }) = TransferRecord;
}
