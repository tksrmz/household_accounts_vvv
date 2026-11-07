import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget.freezed.dart';

/// 支出カテゴリの予算の値オブジェクト。
///
/// 生成できた時点で0以上であることが保証される。予算を立てないカテゴリも
/// ありうるため、金額(1以上の`Amount`)と違って0を許す。
@freezed
class Budget with _$Budget {
  /// [value]が負数のとき[FormatException]を送出する。
  ///
  /// assertはリリースビルドで無効化されるため、検証を呼び出し側の任意に委ねると
  /// 検証漏れの経路が本番でそのまま通ってしまう。誓約は全ビルドで効くthrowで表現し、
  /// 「生成できた＝妥当」を型で保証する。
  ///
  /// 送出するのがErrorではなくExceptionなのは、予算はユーザーが入力欄に
  /// 直接入力しうる値であり、UI層が捕捉して検証エラー表示へ分岐させる
  /// 制御フローに載せたいため(Firestoreから読んだ値が不正な場合も、データの
  /// 不備という想定内の失敗として購読のエラーに載せる)。
  Budget(this.value) {
    if (!isValid(value)) {
      throw FormatException('予算は0以上である必要があります', value);
    }
  }

  /// [value]が予算として妥当(0以上)かどうかを判定する。
  ///
  /// コンストラクタの検証条件と同じ判定をUI層(ライブ検証)からも呼べるように
  /// 公開する。ルールの記述箇所をここ1箇所に絞ることで、コンストラクタの
  /// 例外送出条件と二重管理にならないようにする。
  static bool isValid(int value) {
    return value >= 0;
  }

  /// 予算の整数値。
  final int value;
}
