import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ui_operations.dart';

/// カテゴリ画面(カテゴリ一覧・カテゴリエディタ)の操作ヘルパー。
///
/// 収入・支出のレコードはカテゴリを必ず参照するため、カテゴリはレコードを扱う
/// どのfeatureテストでも前提になる(記録入力・カレンダー・予算)。カテゴリを
/// UIで作る手順が各テストへ増殖しないようここへ集約する。カテゴリ画面
/// そのものの検証はcategory_feature_testが担う。

const _nameLabel = 'カテゴリ名';
const _budgetLabel = '予算';

/// カテゴリタブを開き、収入カテゴリ[name]を1件作成する。
///
/// カテゴリタブを開いた状態から呼んでもよい(同じタブを選び直すだけになる)。
/// 戻ったときにはカテゴリ一覧が表示され、カテゴリはFirestoreへ保存済みに
/// なっている。
Future<void> createIncomeCategory(
  WidgetTester tester, {
  required String name,
}) async {
  await _openCategoryEditorForAdding(tester);
  // 追加エディタは収入を選んだ状態で開くため、種別は選び直さない
  await saveCategoryEditor(tester, name: name);
}

/// カテゴリタブを開き、予算[budget]の支出カテゴリ[name]を1件作成する。
///
/// 前提と戻ったときの状態は[createIncomeCategory]と同じ。
Future<void> createExpenseCategory(
  WidgetTester tester, {
  required String name,
  required int budget,
}) async {
  await _openCategoryEditorForAdding(tester);
  // 予算の入力欄は支出を選んでいる間だけ表示される
  await tester.tap(find.text('支出'));
  await tester.pumpAndSettle();
  await saveCategoryEditor(tester, name: name, budget: budget);
}

/// 開いているカテゴリエディタ(追加・編集)へ入力して「登録」を押し、
/// エディタが閉じるまで待つ。
///
/// [name]・[budget]は、渡したものだけを入力する(渡さない入力欄は開いた時点の
/// 値のまま。編集では編集対象の値が入っている)。入力するときは置き換える。
/// [budget]を渡すときは、支出を選んでいる(予算の入力欄が表示されている)こと。
Future<void> saveCategoryEditor(
  WidgetTester tester, {
  String? name,
  int? budget,
}) async {
  if (name != null) {
    await tester.enterText(find.widgetWithText(TextField, _nameLabel), name);
  }
  if (budget != null) {
    await tester.enterText(
      find.widgetWithText(TextField, _budgetLabel),
      '$budget',
    );
  }
  // 「登録」は入力のライブ検証が通ってから押せるようになる
  await tester.pumpAndSettle();
  await tester.tap(find.text('登録'));

  // エディタは保存の完了(Firestoreの書き込み完了)を待ってから閉じる。
  // 待つ間は描画すべきフレームが無く、pumpAndSettleでは閉じる前に戻ってしまう
  await waitUntil(
    tester,
    () => find.widgetWithText(TextField, _nameLabel).evaluate().isEmpty,
    description: 'カテゴリ「${name ?? '(名前は変更なし)'}」を保存してエディタが閉じること',
  );
  await tester.pumpAndSettle();
}

/// カテゴリタブを開き、追加エディタを開く。
Future<void> _openCategoryEditorForAdding(WidgetTester tester) async {
  await openTab(tester, 'カテゴリ');

  // エディタのAppBarタイトルも同じ文言になるが、エディタを開く前の
  // カテゴリ一覧に存在するのは追加ボタンだけ
  await tester.tap(find.text('カテゴリの追加'));
  await tester.pumpAndSettle();
}
