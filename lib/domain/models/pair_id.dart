import 'package:freezed_annotation/freezed_annotation.dart';

part 'pair_id.freezed.dart';

/// ペアIDの値オブジェクト。
@freezed
class PairId with _$PairId {
  /// [value]が空文字のとき[ArgumentError]を送出する。
  ///
  /// assertはリリースビルドで無効化されるため、誓約は全ビルドで効くthrowで表現する。
  /// ペアIDは共有ノートのドキュメントIDであり、空になるのはユーザーの入力ミスではなく
  /// 不具合の兆候であるため、捕捉されず伝播するErrorを送出してfail fastさせる
  /// (Result.guardもErrorは捕捉しない)。
  PairId(this.value) {
    if (value.isEmpty) {
      throw ArgumentError.value(value, 'value', 'ペアIDは1文字以上である必要があります');
    }
  }

  /// ペアIDの文字列。
  @override
  final String value;
}
