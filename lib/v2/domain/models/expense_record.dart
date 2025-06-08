import 'package:freezed_annotation/freezed_annotation.dart';

import 'expense_category.dart';
import 'property.dart';
import 'vo/record_amount.dart';
import 'vo/record_date.dart';
import 'vo/record_id.dart';
import 'vo/record_note.dart';

part 'expense_record.freezed.dart';

/// 支出レコード
@freezed
abstract class ExpenseRecordModel with _$ExpenseRecordModel {
  const factory ExpenseRecordModel({
    required RecordIdVo id,
    required RecordDateVo recordDate,
    required RecordAmountVo amount,
    required RecordNoteVo note,
    required ExpenseCategoryModel category,
    required PropertyModel property,
    required bool hasCheckedOut,
  }) = _ExpenseRecordModel;

  const ExpenseRecordModel._();
}
