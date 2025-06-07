import 'package:freezed_annotation/freezed_annotation.dart';

part 'record_amount.freezed.dart';

/// レコード金額
@freezed
abstract class RecordAmountVo with _$RecordAmountVo {
  @Assert('value > 0', 'レコード金額は0より大きくなければなりません')
  const factory RecordAmountVo(int value) = _RecordAmountVo;

  const RecordAmountVo._();
}