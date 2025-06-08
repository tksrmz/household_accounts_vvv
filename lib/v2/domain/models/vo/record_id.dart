import 'package:freezed_annotation/freezed_annotation.dart';

part 'record_id.freezed.dart';

/// レコードID
@freezed
abstract class RecordIdVo with _$RecordIdVo {
  @Assert('value.length > 0', 'レコードIDは空にできません')
  const factory RecordIdVo(String value) = _RecordIdVo;

  const RecordIdVo._();
}
