import 'package:freezed_annotation/freezed_annotation.dart';

part 'property_id.freezed.dart';

/// 資産ID
@freezed
abstract class PropertyIdVo with _$PropertyIdVo {
  @Assert('value.length > 0', '資産IDは空にできません')
  const factory PropertyIdVo(String value) = _PropertyIdVo;

  const PropertyIdVo._();
}