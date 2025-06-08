import 'package:freezed_annotation/freezed_annotation.dart';

import 'property.dart';
import 'vo/record_amount.dart';
import 'vo/record_date.dart';
import 'vo/record_id.dart';
import 'vo/record_note.dart';

part 'transfer_record.freezed.dart';

/// 振替レコード
@freezed
abstract class TransferRecordModel with _$TransferRecordModel {
  const factory TransferRecordModel({
    required RecordIdVo id,
    required RecordDateVo recordDate,
    required RecordAmountVo amount,
    required RecordNoteVo note,
    required PropertyModel source,
    required PropertyModel destination,
    required bool hasCheckedOut,
  }) = _TransferRecordModel;

  const TransferRecordModel._();
}
