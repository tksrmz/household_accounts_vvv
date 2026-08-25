import 'package:freezed_annotation/freezed_annotation.dart';

part 'property_id.freezed.dart';

/// 資産IDの値オブジェクト。
@freezed
class PropertyId with _$PropertyId {
  /// [value]が空文字のとき[ArgumentError]を送出する。
  ///
  /// assertはリリースビルドで無効化されるため、誓約は全ビルドで効くthrowで表現する。
  /// 資産IDはFirestoreのドキュメントIDから受け取るシステム内部の値であり、
  /// 空になるのはユーザーの入力ミスではなく不具合の兆候であるため、捕捉されず
  /// 伝播するErrorを送出してfail fastさせる(Result.guardもErrorは捕捉しない)。
  PropertyId(this.value) {
    if (value.isEmpty) {
      throw ArgumentError.value(value, 'value', '資産IDは1文字以上である必要があります');
    }
  }

  /// 資産IDの文字列。
  @override
  final String value;
}
