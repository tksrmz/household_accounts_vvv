import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_name.freezed.dart';

/// ユーザー名の値オブジェクト
@freezed
abstract class UserName with _$UserName {
  /// ユーザー名として許容する最大文字数
  static const int maxLength = 20;

  @Assert(
    'value.length >= 1 && value.length <= UserName.maxLength',
    'ユーザー名は1文字以上20文字以下である必要があります',
  )
  const factory UserName(String value) = _UserName;

  /// [value]がユーザー名として妥当かを検証し、不正なら理由メッセージを、
  /// 妥当なら`null`を返す。
  ///
  /// assertはデバッグビルドでしか効かずリリースビルドでは無効化されるため、
  /// フォームのバリデーションにはassertではなくこちらのstaticメソッドを使う。
  static String? validate(String value) {
    if (value.isEmpty || value.length > maxLength) {
      return '1文字以上20文字以下にしてください';
    }
    return null;
  }
}
