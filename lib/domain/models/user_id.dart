import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_id.freezed.dart';

/// ユーザーIDの値オブジェクト。
@freezed
class UserId with _$UserId {
  /// [value]が空文字のとき[ArgumentError]を送出する。
  ///
  /// assertはリリースビルドで無効化されるため、誓約は全ビルドで効くthrowで表現する。
  /// ユーザーIDは認証基盤から受け取るシステム内部の値であり、空になるのは
  /// ユーザーの入力ミスではなく不具合の兆候であるため、捕捉されず伝播する
  /// Errorを送出してfail fastさせる(Result.guardもErrorは捕捉しない)。
  UserId(this.value) {
    if (value.isEmpty) {
      throw ArgumentError.value(value, 'value', 'ユーザーIDは1文字以上である必要があります');
    }
  }

  /// ユーザーIDの文字列。
  @override
  final String value;
}
