import 'package:freezed_annotation/freezed_annotation.dart';

part 'property_name.freezed.dart';

/// 資産名
@freezed
abstract class PropertyNameVo with _$PropertyNameVo {
  @Assert('value.length > 0 && value.length <= 20', '資産名は1-20文字でなければなりません')
  const factory PropertyNameVo(String value) = _PropertyNameVo;

  const PropertyNameVo._();
}
