import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 記録入力画面(入力タブ)のフォーム操作ヘルパー。
///
/// レコードの作成はレコードを扱うどのfeatureテストでも前提操作になるため
/// (作成の検証はrecord_creating、作成したレコードの削除はcalendar)、
/// 同じ手順が各テストへ増殖しないようここへ集約する。

const _amountLabel = '金額';
const _noteLabel = 'メモ';
const _submitLabel = '登録';
const _submitSucceededMessage = 'レコードを登録しました';

/// 記録入力の種別([label]は'収入'/'支出'/'振替')を切り替える。
Future<void> selectRecordType(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// 金額欄へ[amount]を入力する。
Future<void> enterRecordAmount(WidgetTester tester, int amount) =>
    _enterText(tester, label: _amountLabel, text: '$amount');

/// メモ欄へ[note]を入力する。
Future<void> enterRecordNote(WidgetTester tester, String note) =>
    _enterText(tester, label: _noteLabel, text: note);

/// 選択欄を開き、[label]の選択肢を選ぶ。
///
/// 選択欄はhintのテキストが選択後に消えるため、役割ごとに固定されたキー
/// (category / property / fromProperty / toProperty)で特定する。
/// 選択肢のラベルは閉じた選択欄の中にも存在する(DropdownButtonが全項目を
/// ツリーへ保持するため)ので、あとから重ねて表示されるメニュー側を選ぶ。
Future<void> selectRecordOption(
  WidgetTester tester, {
  required String dropdownKey,
  required String label,
}) async {
  await tester.tap(find.byKey(ValueKey(dropdownKey)));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

/// 登録ボタンを押し、成功のスナックバーが出ることを確認する。
Future<void> submitRecord(WidgetTester tester) async {
  await tester.tap(find.text(_submitLabel));
  await tester.pumpAndSettle();
  expect(find.text(_submitSucceededMessage), findsOneWidget);
}

Future<void> _enterText(
  WidgetTester tester, {
  required String label,
  required String text,
}) async {
  await tester.enterText(find.widgetWithText(TextField, label), text);
  await tester.pumpAndSettle();
}
