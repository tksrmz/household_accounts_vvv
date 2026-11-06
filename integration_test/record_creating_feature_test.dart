import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/main.dart';

import 'util/firestore_probe.dart';
import 'util/firestore_rest.dart';
import 'util/property_operations.dart';
import 'util/record_entry_operations.dart';
import 'util/sign_in.dart';
import 'util/ui_operations.dart';
import 'util/sign_up.dart';

/// 記録入力の受け入れテスト。
///
/// スナックバーの表示だけでなく、Firestoreへ実際に書き込まれた内容
/// (保存先のノート・コレクション、8フィールドの値、参照先、資産残高の増減)を
/// REST APIで直接読み取って検証する。表示だけを見ていると、書き込み先の
/// パス誤りや残高更新の欠落を見逃すため。
Future<void> recordCreatingFeature() async {
  testWidgets('ユーザーは自分の家計簿で収入レコードを作成できるので、収入を正確に記録できる', (tester) async {
    const categoryName = '給料';
    const propertyName = '普通預金';
    const note = '個人収入:6月分給料';
    const amount = 250000;

    await tester.pumpWidget(const MyApp());
    await signUpApp(tester);
    await tester.pumpAndSettle();

    await openTab(tester, 'カテゴリ');
    await _addIncomeCategory(tester, name: categoryName);
    await createProperty(tester, name: propertyName, amount: 100000);

    final notePath = currentPersonalNotePath();
    final balanceBefore = await fetchPropertyAmount(notePath, propertyName);

    await openTab(tester, '入力');
    await enterRecordAmount(tester, amount);
    await selectRecordOption(
      tester,
      dropdownKey: 'category',
      label: categoryName,
    );
    await selectRecordOption(
      tester,
      dropdownKey: 'property',
      label: propertyName,
    );
    await enterRecordNote(tester, note);
    await submitRecord(tester);

    final record = await fetchRecordByNote(notePath, 'incomes', note);
    _expectCommonFields(record, amount: amount, type: 'income');
    await _expectReference(
      record,
      field: 'category',
      collectionPath: '$notePath/incomeCategories',
      name: categoryName,
    );
    await _expectReference(
      record,
      field: 'property',
      collectionPath: '$notePath/properties',
      name: propertyName,
    );

    // 収入は資産残高を増やす
    expect(
      await fetchPropertyAmount(notePath, propertyName),
      balanceBefore + amount,
    );
  });

  testWidgets('ユーザーは自分の家計簿で支出レコードを作成できるので、支出を正確に記録できる', (tester) async {
    const categoryName = '食費';
    const propertyName = '現金';
    const note = '個人支出:コンビニ昼食';
    const amount = 1200;

    await tester.pumpWidget(const MyApp());
    await signUpApp(tester);
    await tester.pumpAndSettle();

    await openTab(tester, 'カテゴリ');
    await _addExpenseCategory(tester, name: categoryName, budget: 50000);
    await createProperty(tester, name: propertyName, amount: 50000);

    final notePath = currentPersonalNotePath();
    final balanceBefore = await fetchPropertyAmount(notePath, propertyName);

    await openTab(tester, '入力');
    await selectRecordType(tester, '支出');
    await enterRecordAmount(tester, amount);
    await selectRecordOption(
      tester,
      dropdownKey: 'category',
      label: categoryName,
    );
    await selectRecordOption(
      tester,
      dropdownKey: 'property',
      label: propertyName,
    );
    await enterRecordNote(tester, note);
    await submitRecord(tester);

    final record = await fetchRecordByNote(notePath, 'expenses', note);
    _expectCommonFields(record, amount: amount, type: 'expense');
    await _expectReference(
      record,
      field: 'category',
      collectionPath: '$notePath/expenseCategories',
      name: categoryName,
    );
    await _expectReference(
      record,
      field: 'property',
      collectionPath: '$notePath/properties',
      name: propertyName,
    );

    // 支出は資産残高を減らす
    expect(
      await fetchPropertyAmount(notePath, propertyName),
      balanceBefore - amount,
    );
  });

  testWidgets('ユーザーは自分の家計簿で振替レコードを作成できるので、資産間の移動を正確に記録できる', (tester) async {
    const fromPropertyName = '普通預金';
    const toPropertyName = '現金';
    const note = '個人振替:現金引き出し';
    const amount = 50000;

    await tester.pumpWidget(const MyApp());
    await signUpApp(tester);
    await tester.pumpAndSettle();

    await createProperty(tester, name: fromPropertyName, amount: 200000);
    await createProperty(tester, name: toPropertyName, amount: 30000);

    final notePath = currentPersonalNotePath();
    final fromBalanceBefore = await fetchPropertyAmount(
      notePath,
      fromPropertyName,
    );
    final toBalanceBefore = await fetchPropertyAmount(notePath, toPropertyName);

    await openTab(tester, '入力');
    await selectRecordType(tester, '振替');
    await enterRecordAmount(tester, amount);
    await selectRecordOption(
      tester,
      dropdownKey: 'fromProperty',
      label: fromPropertyName,
    );
    await selectRecordOption(
      tester,
      dropdownKey: 'toProperty',
      label: toPropertyName,
    );
    await enterRecordNote(tester, note);
    await submitRecord(tester);

    final record = await fetchRecordByNote(notePath, 'transfers', note);
    _expectCommonFields(record, amount: amount, type: 'transfer');
    await _expectReference(
      record,
      field: 'fromProperty',
      collectionPath: '$notePath/properties',
      name: fromPropertyName,
    );
    await _expectReference(
      record,
      field: 'toProperty',
      collectionPath: '$notePath/properties',
      name: toPropertyName,
    );

    // 振替は振替元を減らし、振替先を同額増やす
    expect(
      await fetchPropertyAmount(notePath, fromPropertyName),
      fromBalanceBefore - amount,
    );
    expect(
      await fetchPropertyAmount(notePath, toPropertyName),
      toBalanceBefore + amount,
    );
  });

  testWidgets('ペアリング済みユーザーはふたりの家計簿で収入レコードを作成できるので、共有収入を正確に記録できる', (
    tester,
  ) async {
    const categoryName = '共同収入';
    const propertyName = '共同口座';
    const note = '共有収入:家賃収入';
    const amount = 100000;

    await tester.pumpWidget(const MyApp());
    // FIXME: ペアリング機能未作成の間は、seed済みのペアユーザーでサインインする
    await signInApp(tester, pairUser);
    await tester.pumpAndSettle();
    await switchToSharedNote(tester);

    await openTab(tester, 'カテゴリ');
    await _addIncomeCategory(tester, name: categoryName);
    await createProperty(tester, name: propertyName, amount: 300000);

    final notePath = await currentSharedNotePath();
    final balanceBefore = await fetchPropertyAmount(notePath, propertyName);

    await openTab(tester, '入力');
    await enterRecordAmount(tester, amount);
    await selectRecordOption(
      tester,
      dropdownKey: 'category',
      label: categoryName,
    );
    await selectRecordOption(
      tester,
      dropdownKey: 'property',
      label: propertyName,
    );
    await enterRecordNote(tester, note);
    await submitRecord(tester);

    final record = await fetchRecordByNote(notePath, 'incomes', note);
    _expectCommonFields(record, amount: amount, type: 'income');
    await _expectReference(
      record,
      field: 'category',
      collectionPath: '$notePath/incomeCategories',
      name: categoryName,
    );
    await _expectReference(
      record,
      field: 'property',
      collectionPath: '$notePath/properties',
      name: propertyName,
    );

    expect(
      await fetchPropertyAmount(notePath, propertyName),
      balanceBefore + amount,
    );
  });

  testWidgets('ペアリング済みユーザーはふたりの家計簿で支出レコードを作成できるので、共有支出を正確に記録できる', (
    tester,
  ) async {
    const categoryName = '共同光熱費';
    const propertyName = '共同財布';
    const note = '共有支出:5月分電気代';
    const amount = 25000;

    await tester.pumpWidget(const MyApp());
    // FIXME: ペアリング機能未作成の間は、seed済みのペアユーザーでサインインする
    await signInApp(tester, pairUser);
    await tester.pumpAndSettle();
    await switchToSharedNote(tester);

    await openTab(tester, 'カテゴリ');
    await _addExpenseCategory(tester, name: categoryName, budget: 30000);
    await createProperty(tester, name: propertyName, amount: 300000);

    final notePath = await currentSharedNotePath();
    final balanceBefore = await fetchPropertyAmount(notePath, propertyName);

    await openTab(tester, '入力');
    await selectRecordType(tester, '支出');
    await enterRecordAmount(tester, amount);
    await selectRecordOption(
      tester,
      dropdownKey: 'category',
      label: categoryName,
    );
    await selectRecordOption(
      tester,
      dropdownKey: 'property',
      label: propertyName,
    );
    await enterRecordNote(tester, note);
    await submitRecord(tester);

    final record = await fetchRecordByNote(notePath, 'expenses', note);
    _expectCommonFields(record, amount: amount, type: 'expense');
    await _expectReference(
      record,
      field: 'category',
      collectionPath: '$notePath/expenseCategories',
      name: categoryName,
    );
    await _expectReference(
      record,
      field: 'property',
      collectionPath: '$notePath/properties',
      name: propertyName,
    );

    expect(
      await fetchPropertyAmount(notePath, propertyName),
      balanceBefore - amount,
    );
  });

  testWidgets('ペアリング済みユーザーはふたりの家計簿で振替レコードを作成できるので、共有資産間の移動を正確に記録できる', (
    tester,
  ) async {
    const fromPropertyName = '共同口座A';
    const toPropertyName = '共同口座B';
    const note = '共有振替:積立';
    const amount = 150000;

    await tester.pumpWidget(const MyApp());
    // FIXME: ペアリング機能未作成の間は、seed済みのペアユーザーでサインインする
    await signInApp(tester, pairUser);
    await tester.pumpAndSettle();
    await switchToSharedNote(tester);

    await createProperty(tester, name: fromPropertyName, amount: 300000);
    await createProperty(tester, name: toPropertyName, amount: 200000);

    final notePath = await currentSharedNotePath();
    final fromBalanceBefore = await fetchPropertyAmount(
      notePath,
      fromPropertyName,
    );
    final toBalanceBefore = await fetchPropertyAmount(notePath, toPropertyName);

    await openTab(tester, '入力');
    await selectRecordType(tester, '振替');
    await enterRecordAmount(tester, amount);
    await selectRecordOption(
      tester,
      dropdownKey: 'fromProperty',
      label: fromPropertyName,
    );
    await selectRecordOption(
      tester,
      dropdownKey: 'toProperty',
      label: toPropertyName,
    );
    await enterRecordNote(tester, note);
    await submitRecord(tester);

    // 旧実装は共有ノートを選択していても振替だけを個人ノートへ書き込んでいた。
    // 新実装がノート種別によらず同じパス解決を通ることを、書き込み先そのもので
    // 固定して再発を防ぐ。
    expect(notePath, startsWith('sharedNotes/'));
    final record = await fetchRecordByNote(notePath, 'transfers', note);
    expect(
      await countRecordsByNote(currentPersonalNotePath(), 'transfers', note),
      0,
    );

    _expectCommonFields(record, amount: amount, type: 'transfer');
    await _expectReference(
      record,
      field: 'fromProperty',
      collectionPath: '$notePath/properties',
      name: fromPropertyName,
    );
    await _expectReference(
      record,
      field: 'toProperty',
      collectionPath: '$notePath/properties',
      name: toPropertyName,
    );

    expect(
      await fetchPropertyAmount(notePath, fromPropertyName),
      fromBalanceBefore - amount,
    );
    expect(
      await fetchPropertyAmount(notePath, toPropertyName),
      toBalanceBefore + amount,
    );
  });
}

/// カテゴリ画面で収入カテゴリを1件作成する。
Future<void> _addIncomeCategory(
  WidgetTester tester, {
  required String name,
}) async {
  await tester.tap(find.text('カテゴリの追加'));
  await tester.pumpAndSettle();
  await tester.enterText(find.widgetWithText(TextField, 'カテゴリ名'), name);
  await tester.tap(find.text('登録'));
  await tester.pumpAndSettle();
}

/// カテゴリ画面で支出カテゴリ(予算付き)を1件作成する。
Future<void> _addExpenseCategory(
  WidgetTester tester, {
  required String name,
  required int budget,
}) async {
  await tester.tap(find.text('カテゴリの追加'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('支出'));
  await tester.enterText(find.widgetWithText(TextField, 'カテゴリ名'), name);
  await tester.enterText(find.widgetWithText(TextField, '予算'), '$budget');
  await tester.tap(find.text('登録'));
  await tester.pumpAndSettle();
}

/// 収入/支出/振替に共通する書き込み内容を検証する。
void _expectCommonFields(
  Map<String, dynamic> record, {
  required int amount,
  required String type,
}) {
  expect(readInt(record, 'amount'), amount);
  expect(readString(record, 'type'), type);
  // 作成と同時に残高へ反映済みであることを表すフラグ
  expect(readBool(record, 'hasCheckedOut'), isTrue);
  // createdAtはサーバー時刻で書かれるため、値そのものではなく
  // 書き込まれていること(Rulesが要求するフィールドの欠落がないこと)を見る
  expect(record['createdAt'], isNotNull);
  // 日付は端末ローカルの当日0時。Firestoreは常にUTCで保持するため揃えて比較する
  final today = DateTime.now();
  expect(
    readTimestamp(record, 'date'),
    DateTime(today.year, today.month, today.day).toUtc(),
  );
}

/// レコードの参照フィールドが、`name`が[name]のドキュメントを指すことを検証する。
Future<void> _expectReference(
  Map<String, dynamic> record, {
  required String field,
  required String collectionPath,
  required String name,
}) async {
  expect(
    readReferencePath(readMap(record, field), 'ref'),
    await fetchDocumentPathByName(collectionPath, name),
  );
}
