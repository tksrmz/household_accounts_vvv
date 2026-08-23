import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_name.freezed.dart';

/// ユーザー名の値オブジェクト。
///
/// 生成できた時点で「1文字以上[maxLength]文字以下」であることが保証される。
@freezed
class UserName with _$UserName {
  /// [value]が不正なとき[FormatException]を送出する。
  ///
  /// assertはリリースビルドで無効化されるため、検証を呼び出し側の任意に委ねると
  /// 検証漏れの経路が本番でそのまま通ってしまう。誓約は全ビルドで効くthrowで表現し、
  /// 「生成できた＝妥当」を型で保証する。
  ///
  /// 送出するのがErrorではなくExceptionなのは、ユーザーの入力ミスが想定内の
  /// 事象であり、UI層が捕捉して検証エラー表示へ分岐させる制御フローに載せたいため
  /// (Errorはプログラミングバグを表し、捕捉されずfail fastすべきもの)。
  UserName(this.value) {
    if (value.isEmpty || value.length > maxLength) {
      throw FormatException('ユーザー名は1文字以上$maxLength文字以下である必要があります', value);
    }
  }

  /// ユーザー名として許容する最大文字数。
  static const int maxLength = 20;

  /// ユーザー名の文字列。
  @override
  final String value;
}
