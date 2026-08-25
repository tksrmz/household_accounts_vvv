import 'package:freezed_annotation/freezed_annotation.dart';

part 'amount.freezed.dart';

/// 金額の値オブジェクト。
///
/// 生成できた時点で1以上であることが保証される。
@freezed
class Amount with _$Amount {
  /// [value]が0以下のとき[FormatException]を送出する。
  ///
  /// assertはリリースビルドで無効化されるため、検証を呼び出し側の任意に委ねると
  /// 検証漏れの経路が本番でそのまま通ってしまう。誓約は全ビルドで効くthrowで表現し、
  /// 「生成できた＝妥当」を型で保証する。
  ///
  /// 送出するのがErrorではなくExceptionなのは、金額はユーザーが入力欄に
  /// 直接入力しうる値であり、UI層が捕捉して検証エラー表示へ分岐させる
  /// 制御フローに載せたいため(Errorはプログラミングバグを表し、
  /// 捕捉されずfail fastすべきもの)。
  Amount(this.value) {
    if (value <= 0) {
      throw FormatException('金額は1以上である必要があります', value);
    }
  }

  /// 金額の整数値。
  @override
  final int value;
}
