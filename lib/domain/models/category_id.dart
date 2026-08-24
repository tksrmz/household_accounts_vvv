import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_id.freezed.dart';

/// カテゴリ(収入/支出)IDの値オブジェクト。
@freezed
class CategoryId with _$CategoryId {
  /// [value]が空文字のとき[ArgumentError]を送出する。
  ///
  /// assertはリリースビルドで無効化されるため、誓約は全ビルドで効くthrowで表現する。
  /// カテゴリIDはFirestoreのドキュメントIDから受け取るシステム内部の値であり、
  /// 空になるのはユーザーの入力ミスではなく不具合の兆候であるため、捕捉されず
  /// 伝播するErrorを送出してfail fastさせる(Result.guardもErrorは捕捉しない)。
  CategoryId(this.value) {
    if (value.isEmpty) {
      throw ArgumentError.value(value, 'value', 'カテゴリIDは1文字以上である必要があります');
    }
  }

  /// カテゴリIDの文字列。
  @override
  final String value;
}
