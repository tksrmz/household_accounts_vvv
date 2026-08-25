import 'package:freezed_annotation/freezed_annotation.dart';

part 'record_note.freezed.dart';

/// レコード(収入/支出/振替)のメモの値オブジェクト。
///
/// 生成できた時点で[maxLength]文字以下であることが保証される。空文字は許容する
/// (メモは任意入力のため)。
@freezed
class RecordNote with _$RecordNote {
  /// [value]が不正なとき[FormatException]を送出する。
  ///
  /// assertはリリースビルドで無効化されるため、検証を呼び出し側の任意に委ねると
  /// 検証漏れの経路が本番でそのまま通ってしまう。誓約は全ビルドで効くthrowで表現し、
  /// 「生成できた＝妥当」を型で保証する。
  ///
  /// 送出するのがErrorではなくExceptionなのは、ユーザーの入力ミスが想定内の
  /// 事象であり、UI層が捕捉して検証エラー表示へ分岐させる制御フローに載せたいため
  /// (Errorはプログラミングバグを表し、捕捉されずfail fastすべきもの)。
  RecordNote(this.value) {
    if (!isValid(value)) {
      throw FormatException('メモは$maxLength文字以下である必要があります', value);
    }
  }

  /// メモとして許容する最大文字数。
  static const int maxLength = 100;

  /// [value]がメモとして妥当([maxLength]文字以下)かどうかを判定する。
  ///
  /// コンストラクタの検証条件と同じ判定をUI層(ライブ検証)からも呼べるように
  /// 公開する。ルールの記述箇所をここ1箇所に絞ることで、コンストラクタの
  /// 例外送出条件と二重管理にならないようにする。
  static bool isValid(String value) {
    return value.length <= maxLength;
  }

  /// メモの文字列。
  @override
  final String value;
}
