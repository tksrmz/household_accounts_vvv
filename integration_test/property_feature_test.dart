import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/main.dart';

import 'util/firestore_probe.dart';
import 'util/property_operations.dart';
import 'util/sign_in.dart';
import 'util/sign_up.dart';
import 'util/ui_operations.dart';

/// 資産(資産一覧と資産エディタ)の受け入れテスト。
///
/// 画面の表示だけでなく、Firestoreへ実際に書き込まれた内容(保存先のノート、
/// `name`・`amount`の値、編集で同じドキュメントが更新されること、削除で
/// ドキュメントが消えること)もREST APIで直接確認する。表示だけを見ていると、
/// 誤ったノートへの書き込みや、編集のつもりで別の資産を作っていることを
/// 見逃すため。
///
/// 資産名はこのファイル固有の名前にする。integrationテストは1回の
/// エミュレータ起動を共有しており、共有ノートには他のfeatureテストが作った
/// 資産も並ぶため。
Future<void> propertyFeature() async {
  testWidgets('ユーザーは自分の家計簿で資産を管理できるので、資産状況を正確に把握できる', (tester) async {
    const savingsName = '資産画面:普通預金';
    const cashName = '資産画面:現金';
    const editedSavingsName = '資産画面:普通預金(メイン)';

    await tester.pumpWidget(const MyApp());
    await signUpApp(tester);
    await tester.pumpAndSettle();

    await createProperty(tester, name: savingsName, amount: 100000);
    await createProperty(tester, name: cashName, amount: 30000);

    _expectPropertyRow(savingsName, '¥100,000');
    _expectPropertyRow(cashName, '¥30,000');

    final notePath = currentPersonalNotePath();
    expect(await fetchPropertyAmount(notePath, savingsName), 100000);
    expect(await fetchPropertyAmount(notePath, cashName), 30000);
    final savingsPath = await fetchDocumentPathByName(
      '$notePath/properties',
      savingsName,
    );

    // 名前と残高をどちらも変更する
    await _tapRowIcon(tester, savingsName, Icons.edit);
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('編集')),
      findsOneWidget,
    );
    await savePropertyEditor(tester, name: editedSavingsName, amount: 120000);

    _expectPropertyRow(editedSavingsName, '¥120,000');
    expect(find.text(savingsName), findsNothing);
    expect(find.text('¥100,000'), findsNothing);
    // 編集していない資産はそのまま残る
    _expectPropertyRow(cashName, '¥30,000');

    expect(await fetchPropertyAmount(notePath, editedSavingsName), 120000);
    expect(await countPropertiesByName(notePath, savingsName), 0);
    // 編集は新しい資産を作るのではなく、元の資産のドキュメントを書き換える
    expect(
      await fetchDocumentPathByName('$notePath/properties', editedSavingsName),
      savingsPath,
    );

    // 確認ダイアログで「削除しない」を選ぶと何も消えない
    await _tapRowIcon(tester, editedSavingsName, Icons.delete);
    expect(find.text('本当に「$editedSavingsName」を削除しますか？'), findsOneWidget);
    await tester.tap(find.text('削除しない'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    _expectPropertyRow(editedSavingsName, '¥120,000');
    expect(await countPropertiesByName(notePath, editedSavingsName), 1);

    // 「削除する」を選ぶと資産が消える
    await _tapRowIcon(tester, editedSavingsName, Icons.delete);
    await tester.tap(find.text('削除する'));
    await tester.pumpAndSettle();

    // 削除後に一覧を取り直す実装は無い。行が消えるのは資産の購読が削除を
    // 反映するからであり、それ自体がリアルタイム反映の検証になる
    await waitUntil(
      tester,
      () => find.text(editedSavingsName).evaluate().isEmpty,
      description: '削除した資産が一覧から消えること',
    );
    expect(find.text('¥120,000'), findsNothing);
    await waitUntil(
      tester,
      () async => await countPropertiesByName(notePath, editedSavingsName) == 0,
      description: '削除した資産のドキュメントが消えること',
    );
    // 削除していない資産は残る
    _expectPropertyRow(cashName, '¥30,000');
    expect(await fetchPropertyAmount(notePath, cashName), 30000);
  });

  testWidgets('ペアリング済みユーザーはふたりの家計簿で資産を管理できるので、共有資産状況を正確に把握できる', (tester) async {
    const sharedAccountName = '資産画面:共同口座';
    const editedSharedAccountName = '資産画面:共同口座(住宅ローン)';

    await tester.pumpWidget(const MyApp());
    // FIXME: ペアリング機能未作成の間は、seed済みのペアユーザーでサインインする
    await signInApp(tester, pairUser);
    await tester.pumpAndSettle();
    await switchToSharedNote(tester);

    await createProperty(tester, name: sharedAccountName, amount: 200000);
    _expectPropertyRow(sharedAccountName, '¥200,000');

    final notePath = await currentSharedNotePath();
    expect(notePath, startsWith('sharedNotes/'));
    expect(await fetchPropertyAmount(notePath, sharedAccountName), 200000);
    // 共有ノートを選んでいるときは、個人ノートへは書き込まない
    final personalNotePath = currentPersonalNotePath();
    expect(await countPropertiesByName(personalNotePath, sharedAccountName), 0);

    await _tapRowIcon(tester, sharedAccountName, Icons.edit);
    await savePropertyEditor(
      tester,
      name: editedSharedAccountName,
      amount: 250000,
    );

    _expectPropertyRow(editedSharedAccountName, '¥250,000');
    expect(find.text(sharedAccountName), findsNothing);
    expect(
      await fetchPropertyAmount(notePath, editedSharedAccountName),
      250000,
    );
    expect(await countPropertiesByName(notePath, sharedAccountName), 0);
    expect(
      await countPropertiesByName(personalNotePath, editedSharedAccountName),
      0,
    );

    await _tapRowIcon(tester, editedSharedAccountName, Icons.delete);
    await tester.tap(find.text('削除する'));
    await tester.pumpAndSettle();

    await waitUntil(
      tester,
      () => find.text(editedSharedAccountName).evaluate().isEmpty,
      description: '削除した共有資産が一覧から消えること',
    );
    await waitUntil(
      tester,
      () async =>
          await countPropertiesByName(notePath, editedSharedAccountName) == 0,
      description: '削除した共有資産のドキュメントが消えること',
    );
  });
}

/// 資産一覧で、[name]を表示している行。
Finder _rowOf(String name) =>
    find.ancestor(of: find.text(name), matching: find.byType(Row)).first;

/// 資産一覧に、[name]の資産が残高[balanceText]で1行だけ表示されていることを
/// 検証する。
void _expectPropertyRow(String name, String balanceText) {
  expect(find.text(name), findsOneWidget);
  expect(
    find.descendant(of: _rowOf(name), matching: find.text(balanceText)),
    findsOneWidget,
  );
}

/// 資産一覧で、[name]の行の[icon](編集/削除)を押す。
///
/// 共有ノートの一覧には他のテストが作った資産も並ぶため、位置ではなく
/// 資産名で行を特定する。
Future<void> _tapRowIcon(
  WidgetTester tester,
  String name,
  IconData icon,
) async {
  final button = find.descendant(of: _rowOf(name), matching: find.byIcon(icon));
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}
