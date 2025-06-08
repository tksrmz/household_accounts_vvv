import 'package:freezed_annotation/freezed_annotation.dart';

import 'income_category.dart';
import 'property.dart';
import 'vo/record_amount.dart';
import 'vo/record_date.dart';
import 'vo/record_id.dart';
import 'vo/record_note.dart';

part 'income_record.freezed.dart';

/// 収入レコード
@freezed
abstract class IncomeRecordModel with _$IncomeRecordModel {
  const factory IncomeRecordModel({
    required RecordIdVo id,
    required RecordDateVo recordDate,
    required RecordAmountVo amount,
    required RecordNoteVo note,
    required IncomeCategoryModel category,
    required PropertyModel property,
    required bool hasCheckedOut,
  }) = _IncomeRecordModel;

  const IncomeRecordModel._();
}
