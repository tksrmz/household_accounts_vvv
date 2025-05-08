import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_name.freezed.dart';

/// UserName entity.
@freezed
class UserNameVo with _$UserNameVo {
  /// 最大の文字数
  static const maxLength = 20;

  /// 初期化前のユーザー名
  static const empty = UserNameVo._empty();

  const UserNameVo(this.value)
      : assert(value.length > 0, 'ユーザー名は1文字以上である必要があります'),
        assert(value.length <= maxLength, 'ユーザー名は20文字以下である必要があります');

  const UserNameVo._empty() : value = '';

  @override
  final String value;

  /// 有効なユーザー名かどうか
  static bool isValid(String str) => str.isNotEmpty && str.length <= maxLength;
}
