import 'package:freezed_annotation/freezed_annotation.dart';

part 'property_name.freezed.dart';

/// 資産名の値オブジェクト。
///
/// 生成できた時点で「1文字以上[maxLength]文字以下」であることが保証される。
@freezed
class PropertyName with _$PropertyName {
  /// [value]が不正なとき[FormatException]を送出する。
  ///
  /// assertはリリースビルドで無効化されるため、検証を呼び出し側の任意に委ねると
  /// 検証漏れの経路が本番でそのまま通ってしまう。誓約は全ビルドで効くthrowで表現し、
  /// 「生成できた＝妥当」を型で保証する。
  ///
  /// 送出するのがErrorではなくExceptionなのは、ユーザーの入力ミスが想定内の
  /// 事象であり、UI層が捕捉して検証エラー表示へ分岐させる制御フローに載せたいため
  /// (Errorはプログラミングバグを表し、捕捉されずfail fastすべきもの)。
  PropertyName(this.value) {
    if (!isValid(value)) {
      throw FormatException('資産名は1文字以上$maxLength文字以下である必要があります', value);
    }
  }

  /// 資産名として許容する最大文字数。
  static const int maxLength = 20;

  /// [value]が資産名として妥当(1文字以上[maxLength]文字以下)かどうかを判定する。
  ///
  /// コンストラクタの検証条件と同じ判定をUI層(ライブ検証)からも呼べるように
  /// 公開する。ルールの記述箇所をここ1箇所に絞ることで、コンストラクタの
  /// 例外送出条件と二重管理にならないようにする。
  static bool isValid(String value) {
    return value.isNotEmpty && value.length <= maxLength;
  }

  /// 資産名の文字列。
  @override
  final String value;
}
