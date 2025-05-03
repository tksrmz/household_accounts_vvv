import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_name.freezed.dart';

/// UserName entity.
@freezed
abstract class UserNameVo with _$UserNameVo {
  /// 最大の文字数
  static const maxLength = 20;

  @Assert('value.length > 0', 'ユーザー名は1文字以上である必要があります')
  @Assert('value.length <= ${maxLength}', 'ユーザー名は20文字以下である必要があります')
  const factory UserNameVo(String value) = _UserNameVo;
}
