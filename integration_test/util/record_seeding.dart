import 'package:flutter_test/flutter_test.dart';

import 'firestore_probe.dart';
import 'firestore_rest.dart';

/// featureテストの前提となるレコードを用意するヘルパー関数群。
///
/// レコードが参照するカテゴリ・資産はUI操作で作る(操作は
/// category_operations.dart・property_operations.dartにまとめてある)。
///
/// 支出レコードだけはFirestoreエミュレータのREST APIで直接書き込む。
/// 新しい記録入力画面は日付の選択範囲を当日までに制限しており、月度境界の
/// フィクスチャに必要な未来日付(月度end当日など、実行日によっては未来になる)を
/// UIからは投入できなくなったため。

/// サインイン中ユーザーの個人ノートへ、指定した[date]・[amount]・
/// [categoryName]・[propertyName]・[note]の支出レコードを1件書き込む。
///
/// 書き込む8フィールドは、Firestore Rulesが要求するスキーマ
/// (date/amount/note/createdAt/hasCheckedOut/type/category/property)と
/// 一致させてある。旧実装の読み取り(予算タブ)と新実装のRecordDtoの検証は
/// どちらもこの形を前提にしているため、片方だけを満たす形にはしない。
///
/// 資産残高([propertyName]のamount)は増減させない。予算タブは残高を参照せず、
/// 残高の自動増減はrecord_creating_feature_test.dartが検証するため。
///
/// [tester]は使わないが、UI操作でseedしていた頃からの呼び出し側
/// (budget_feature_test.dart)を変更せずに済むよう引数に残している。
Future<void> createExpenseRecord(
  WidgetTester tester, {
  required DateTime date,
  required int amount,
  required String categoryName,
  required String propertyName,
  required String note,
}) async {
  final notePath = currentPersonalNotePath();
  final categoryPath = await fetchDocumentPathByName(
    '$notePath/expenseCategories',
    categoryName,
  );
  final propertyPath = await fetchDocumentPathByName(
    '$notePath/properties',
    propertyName,
  );

  await useFirestoreRest(
    (rest) => rest.createDocument('$notePath/expenses', {
      'date': timestampValue(date),
      'amount': integerValue(amount),
      'note': stringValue(note),
      // アプリはserverTimestampを書くが、REST APIにセンチネルは無いため
      // 書き込み時刻をそのまま入れる(読み取り側は値を検証しない)
      'createdAt': timestampValue(DateTime.now()),
      'hasCheckedOut': booleanValue(true),
      'type': stringValue('expense'),
      'category': mapValue({'ref': referenceValue(categoryPath)}),
      'property': mapValue({'ref': referenceValue(propertyPath)}),
    }),
  );
}
