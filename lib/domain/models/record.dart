import 'package:freezed_annotation/freezed_annotation.dart';

import 'amount.dart';
import 'category_id.dart';
import 'property_id.dart';
import 'record_content.dart';
import 'record_date.dart';
import 'record_id.dart';
import 'record_note.dart';

part 'record.freezed.dart';

/// 収入/支出/振替の記録を表すsealed union。
@freezed
sealed class Record with _$Record {
  const Record._();

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

  /// この保存済みレコードの内容。残高への寄与の計算([RecordContent.balanceEffects])
  /// など、IDを必要としない操作はこちらを介して行う。
  RecordContent get content => switch (this) {
    IncomeRecord(
      :final date,
      :final amount,
      :final note,
      :final categoryId,
      :final propertyId,
    ) =>
      RecordContent.income(
        date: date,
        amount: amount,
        note: note,
        categoryId: categoryId,
        propertyId: propertyId,
      ),
    ExpenseRecord(
      :final date,
      :final amount,
      :final note,
      :final categoryId,
      :final propertyId,
    ) =>
      RecordContent.expense(
        date: date,
        amount: amount,
        note: note,
        categoryId: categoryId,
        propertyId: propertyId,
      ),
    TransferRecord(
      :final date,
      :final amount,
      :final note,
      :final fromPropertyId,
      :final toPropertyId,
    ) =>
      RecordContent.transfer(
        date: date,
        amount: amount,
        note: note,
        fromPropertyId: fromPropertyId,
        toPropertyId: toPropertyId,
      ),
  };
}
