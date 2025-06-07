import 'package:freezed_annotation/freezed_annotation.dart';

part 'record_note.freezed.dart';

/// レコードメモ
@freezed
abstract class RecordNoteVo with _$RecordNoteVo {
  @Assert('value.length <= 100', 'レコードメモは100文字以下でなければなりません')
  const factory RecordNoteVo(String value) = _RecordNoteVo;

  const RecordNoteVo._();
}