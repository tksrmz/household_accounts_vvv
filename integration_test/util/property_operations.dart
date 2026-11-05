import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ui_operations.dart';

/// 資産画面(資産一覧・資産エディタ)の操作ヘルパー。
///
/// 資産はレコードを扱うどのfeatureテストでも前提になるため(記録入力・
/// カレンダー・予算)、資産をUIで作る手順が各テストへ増殖しないよう
/// ここへ集約する。資産画面そのものの検証はproperty_feature_testが担う。

const _nameLabel = '資産名';
const _balanceLabel = '資産額';

/// 資産タブを開き、資産[name]を残高[amount]で1件作成する。
///
/// 資産タブを開いた状態から呼んでもよい(同じタブを選び直すだけになる)。
/// 戻ったときには資産一覧が表示され、資産はFirestoreへ保存済みになっている。
Future<void> createProperty(
  WidgetTester tester, {
  required String name,
  required int amount,
}) async {
  await openTab(tester, '資産');

  // エディタのAppBarタイトルも同じ文言になるが、エディタを開く前の
  // 資産一覧に存在するのは追加ボタンだけ
  await tester.tap(find.text('資産の追加'));
  await tester.pumpAndSettle();

  await savePropertyEditor(tester, name: name, amount: amount);
}

/// 開いている資産エディタ(追加・編集)へ[name]と[amount]を入力して保存し、
/// エディタが閉じるまで待つ。
///
/// 編集では入力欄に編集対象の値が入っているが、置き換えて入力する。
Future<void> savePropertyEditor(
  WidgetTester tester, {
  required String name,
  required int amount,
}) async {
  await tester.enterText(find.widgetWithText(TextField, _nameLabel), name);
  await tester.enterText(
    find.widgetWithText(TextField, _balanceLabel),
    '$amount',
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('保存'));

  // エディタは保存の完了(Firestoreの書き込み完了)を待ってから閉じる。
  // 待つ間は描画すべきフレームが無く、pumpAndSettleでは閉じる前に戻ってしまう
  await waitUntil(
    tester,
    () => find.widgetWithText(TextField, _nameLabel).evaluate().isEmpty,
    description: '資産「$name」を保存してエディタが閉じること',
  );
  await tester.pumpAndSettle();
}
