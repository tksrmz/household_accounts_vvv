import 'package:freezed_annotation/freezed_annotation.dart';

import 'property.dart';
import 'vo/record_amount.dart';
import 'vo/record_date.dart';
import 'vo/record_id.dart';
import 'vo/record_note.dart';

part 'transfer_record.freezed.dart';

/// 振替レコード
@freezed
abstract class TransferRecordVo with _$TransferRecordVo {
  const factory TransferRecordVo({
    required RecordIdVo id,
    required RecordDateVo recordDate,
    required RecordAmountVo amount,
    required RecordNoteVo note,
    required PropertyVo source,
    required PropertyVo destination,
    required bool hasCheckedOut,
  }) = _TransferRecordVo;

  const TransferRecordVo._();
}