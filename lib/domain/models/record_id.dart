import 'package:freezed_annotation/freezed_annotation.dart';

part 'record_id.freezed.dart';

/// レコード(収入/支出/振替)IDの値オブジェクト。
@freezed
class RecordId with _$RecordId {
  /// [value]が空文字のとき[ArgumentError]を送出する。
  ///
  /// assertはリリースビルドで無効化されるため、誓約は全ビルドで効くthrowで表現する。
  /// レコードIDはFirestoreのドキュメントIDから受け取るシステム内部の値であり、
  /// 空になるのはユーザーの入力ミスではなく不具合の兆候であるため、捕捉されず
  /// 伝播するErrorを送出してfail fastさせる(Result.guardもErrorは捕捉しない)。
  RecordId(this.value) {
    if (value.isEmpty) {
      throw ArgumentError.value(value, 'value', 'レコードIDは1文字以上である必要があります');
    }
  }

  /// レコードIDの文字列。
  final String value;
}
