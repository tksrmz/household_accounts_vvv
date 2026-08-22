import 'package:freezed_annotation/freezed_annotation.dart';

part 'pair_id.freezed.dart';

/// ペアIDの値オブジェクト
@freezed
abstract class PairId with _$PairId {
  @Assert('value.length > 0', 'ペアIDは1文字以上である必要があります')
  const factory PairId(String value) = _PairId;
}
