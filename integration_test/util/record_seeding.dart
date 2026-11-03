import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'firestore_probe.dart';
import 'firestore_rest.dart';
import 'ui_operations.dart';

/// featureテストの前提となるカテゴリ・資産・レコードを用意するヘルパー関数群。
///
/// カテゴリと資産はUI操作で作る(カテゴリ画面・資産画面は現行の実装であり、
/// 入力できない値も無いため、既存のintegrationテストと同じ流儀で作れる)。
///
/// 支出レコードだけはFirestoreエミュレータのREST APIで直接書き込む。
/// 新しい記録入力画面は日付の選択範囲を当日までに制限しており、月度境界の
/// フィクスチャに必要な未来日付(月度end当日など、実行日によっては未来になる)を
/// UIからは投入できなくなったため。

/// カテゴリ画面で収入カテゴリを1件作成する。
///
/// 事前条件: ボトムナビゲーションからアクセス可能な画面にいること。
Future<void> createIncomeCategory(
  WidgetTester tester, {
  required String name,
}) async {
  await openTab(tester, 'カテゴリ');

  await tester.tap(find.text('カテゴリの追加'));
  await tester.pumpAndSettle();

  await tester.enterText(find.widgetWithText(TextField, 'カテゴリ名'), name);
  await tester.tap(find.text('登録'));
  await tester.pumpAndSettle();
}

/// カテゴリ画面で支出カテゴリ（予算付き）を1件作成する。
///
/// 事前条件: ボトムナビゲーションからアクセス可能な画面にいること。
Future<void> createExpenseCategory(
  WidgetTester tester, {
  required String name,
  required int budget,
}) async {
  await openTab(tester, 'カテゴリ');

  await tester.tap(find.text('カテゴリの追加'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('支出'));
  await tester.enterText(find.widgetWithText(TextField, 'カテゴリ名'), name);
  await tester.enterText(find.widgetWithText(TextField, '予算'), '$budget');
  await tester.tap(find.text('登録'));
  await tester.pumpAndSettle();
}

/// 資産画面で資産を1件作成する。
Future<void> createProperty(
  WidgetTester tester, {
  required String name,
  required int amount,
}) async {
  await openTab(tester, '資産');

  await tester.tap(find.text('資産の追加'));
  await tester.pumpAndSettle();

  await tester.enterText(find.widgetWithText(TextField, '資産名'), name);
  await tester.enterText(find.widgetWithText(TextField, '資産額'), '$amount');
  await tester.tap(find.text('保存'));
  await tester.pumpAndSettle();
}

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
