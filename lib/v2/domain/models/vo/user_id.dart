import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_id.freezed.dart';

@freezed
abstract class UserIdVo with _$UserIdVo {
  @Assert('value.length > 0', 'ユーザーIDは1文字以上である必要があります')
  const factory UserIdVo(String value) = _UserIdVo;
}
