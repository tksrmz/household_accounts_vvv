import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// budget_feature_test.dart で使用する、支出カテゴリ・資産・境界日の
/// 支出レコードをUI操作でseedするためのヘルパー関数群。
///
/// なぜUI操作でseedするか:
/// 既存のintegrationテスト（category_feature_test.dart 等）が一貫して
/// UI操作によるデータ投入を採用しており、Firestoreへの直接書き込みを
/// 行うヘルパーはこのプロジェクトに存在しないため、既存パターンを踏襲する。

/// カテゴリ画面で支出カテゴリ（予算付き）を1件作成する。
///
/// 事前条件: ボトムナビゲーションからアクセス可能な画面にいること。
Future<void> createExpenseCategory(
  WidgetTester tester, {
  required String name,
  required int budget,
}) async {
  await tester.tap(find.text('カテゴリ'));
  await tester.pumpAndSettle();

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
  await tester.tap(find.text('資産'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('資産の追加'));
  await tester.pumpAndSettle();

  await tester.enterText(find.widgetWithText(TextField, '資産名'), name);
  await tester.enterText(find.widgetWithText(TextField, '資産額'), '$amount');
  await tester.tap(find.text('保存'));
  await tester.pumpAndSettle();
}

/// 入力画面で、指定した[date]・[amount]・[categoryName]・[propertyName]の
/// 支出レコードを1件登録する。
///
/// [date]の指定方法: 標準の[showDatePicker]ダイアログを「キーボード入力モード」に
/// 切り替え、mm/dd/yyyy形式でテキスト入力する。カレンダーグリッドを直接タップする
/// 方式は月またぎのナビゲーションが煩雑なため採用しない。
/// アプリは[MaterialApp.localizationsDelegates]を指定していないため、
/// ロケールは既定のen_US（[DefaultMaterialLocalizations]）であり、
/// 日付入力フォーマットは "mm/dd/yyyy"、確定ボタンラベルは "OK" になる。
Future<void> createExpenseRecord(
  WidgetTester tester, {
  required DateTime date,
  required int amount,
  required String categoryName,
  required String propertyName,
  required String note,
}) async {
  // AppBarのタイトルと入力タブのボトムナビゲーションラベルがどちらも"入力"であるため、
  // 既に入力タブを表示中は単純な find.text('入力') だと2件ヒットしてタップが曖昧になる。
  // ボトムナビゲーションバー配下に絞って一意に特定する。
  await tester.tap(
    find.descendant(
      of: find.byType(BottomNavigationBar),
      matching: find.text('入力'),
    ),
  );
  await tester.pumpAndSettle();

  // go_routerシェル移行後はタブ再訪でも入力フォームのWidgetが再生成されない
  // (IndexedStackのステート保持)ため、2件目以降は前回のカテゴリ・資産の選択が
  // 残り「カテゴリを選択」等のプレースホルダが存在しない。種別を一度「収入」に
  // 切り替えてから「支出」へ戻すことで、種別変更時のドロップダウンリセットを
  // 確実に発火させる(現在選択中の種別ボタンは無効化されており、同じ種別への
  // タップではリセットが起きないため、必ず一往復させる)。
  await tester.tap(find.text('収入'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('支出'));
  await tester.pumpAndSettle();

  await _pickRecordDate(tester, date);

  await tester.enterText(find.widgetWithText(TextField, '金額'), '$amount');

  await tester.tap(find.text('カテゴリを選択'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(categoryName).last);
  await tester.pumpAndSettle();

  await tester.tap(find.text('資産を選択'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(propertyName).last);
  await tester.pumpAndSettle();

  await tester.enterText(find.widgetWithText(TextField, 'ノート'), note);

  await tester.tap(find.text('登録'));
  await tester.pumpAndSettle();
}

/// 入力画面の日付編集アイコンをタップして[showDatePicker]ダイアログを開き、
/// キーボード入力モードに切り替えて[date]をmm/dd/yyyy形式で入力・確定する。
Future<void> _pickRecordDate(WidgetTester tester, DateTime date) async {
  await tester.tap(find.byIcon(Icons.edit));
  await tester.pumpAndSettle();

  // ダイアログをキーボード入力モードに切り替える
  // (Material3 既定では edit_outlined アイコンで入力モードへ切替わる)
  final switchToInputIcon = find.byIcon(Icons.edit_outlined);
  if (switchToInputIcon.evaluate().isNotEmpty) {
    await tester.tap(switchToInputIcon);
    await tester.pumpAndSettle();
  }

  final mmddyyyy =
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.year.toString().padLeft(4, '0')}';

  // ダイアログ(Dialog)内のTextFormFieldに絞り込む
  // (背景の入力画面にもTextFormField（ノート欄等）が存在するため)
  final dateInputField = find.descendant(
    of: find.byType(Dialog),
    matching: find.byType(TextFormField),
  );
  await tester.enterText(dateInputField, mmddyyyy);
  await tester.pumpAndSettle();

  await tester.tap(
    find.descendant(of: find.byType(Dialog), matching: find.text('OK')),
  );
  await tester.pumpAndSettle();
}
