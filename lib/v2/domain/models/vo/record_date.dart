import 'package:freezed_annotation/freezed_annotation.dart';

part 'record_date.freezed.dart';

/// レコード日付
@freezed
abstract class RecordDateVo with _$RecordDateVo {
  const factory RecordDateVo(DateTime value) = _RecordDateVo;

  const RecordDateVo._();
}
