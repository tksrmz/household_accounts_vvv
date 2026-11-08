import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/main.dart';

import 'util/category_operations.dart';
import 'util/firestore_probe.dart';
import 'util/firestore_rest.dart';
import 'util/sign_in.dart';
import 'util/sign_up.dart';
import 'util/ui_operations.dart';

/// カテゴリ(カテゴリ一覧とカテゴリエディタ)の受け入れテスト。
///
/// 画面の表示だけでなく、Firestoreへ実際に書き込まれた内容(保存先のノートと
/// コレクション、`name`・`type`・`totalBudget`の値、編集で同じドキュメントが
/// 更新されること、削除でドキュメントが消えること)もREST APIで直接確認する。
/// 表示だけを見ていると、誤ったノートや誤った種別のコレクションへの書き込み、
/// 編集のつもりで別のカテゴリを作っていることを見逃すため。
///
/// カテゴリ名はこのファイル固有の名前にする。integrationテストは1回の
/// エミュレータ起動を共有しており、共有ノートには他のfeatureテストが作った
/// カテゴリも並ぶため。
Future<void> categoryFeature() async {
  testWidgets('ユーザーは自分の家計簿でカテゴリを管理できるので、収支をカテゴリ別に整理できる', (tester) async {
    const salaryName = 'カテゴリ画面:給料';
    const editedSalaryName = 'カテゴリ画面:月給';
    const foodName = 'カテゴリ画面:食費';

    await tester.pumpWidget(const MyApp());
    await signUpApp(tester);
    await tester.pumpAndSettle();

    // 新規ユーザーにはカテゴリが無い
    await openTab(tester, 'カテゴリ');
    expect(find.text('収入カテゴリがありません。新規追加してください'), findsOneWidget);
    expect(find.text('支出カテゴリがありません。新規追加してください'), findsOneWidget);

    await createIncomeCategory(tester, name: salaryName);
    await createExpenseCategory(tester, name: foodName, budget: 30000);

    expect(find.text(salaryName), findsOneWidget);
    expect(find.text('$foodName (予算: ¥30,000)'), findsOneWidget);
    expect(find.text('収入カテゴリがありません。新規追加してください'), findsNothing);
    expect(find.text('支出カテゴリがありません。新規追加してください'), findsNothing);

    final notePath = currentPersonalNotePath();
    final incomePath = '$notePath/incomeCategories';
    final expensePath = '$notePath/expenseCategories';
    _expectIncomeCategoryFields(
      await fetchFieldsByName(incomePath, salaryName),
      name: salaryName,
    );
    _expectExpenseCategoryFields(
      await fetchFieldsByName(expensePath, foodName),
      name: foodName,
      budget: 30000,
    );
    // 種別ごとに別のコレクションへ書かれる
    expect(await countDocumentsByName(expensePath, salaryName), 0);
    expect(await countDocumentsByName(incomePath, foodName), 0);
    final salaryDocumentPath = await fetchDocumentPathByName(
      incomePath,
      salaryName,
    );
    final foodDocumentPath = await fetchDocumentPathByName(
      expensePath,
      foodName,
    );

    // 収入カテゴリの名前を変更する
    await tapCategoryRowIcon(tester, salaryName, Icons.edit);
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('編集')),
      findsOneWidget,
    );
    await saveCategoryEditor(tester, name: editedSalaryName);

    expect(find.text(editedSalaryName), findsOneWidget);
    expect(find.text(salaryName), findsNothing);
    _expectIncomeCategoryFields(
      await fetchFieldsByName(incomePath, editedSalaryName),
      name: editedSalaryName,
    );
    expect(await countDocumentsByName(incomePath, salaryName), 0);
    // 編集は新しいカテゴリを作るのではなく、元のカテゴリのドキュメントを書き換える
    expect(
      await fetchDocumentPathByName(incomePath, editedSalaryName),
      salaryDocumentPath,
    );

    // 支出カテゴリの予算だけを変更する(名前の入力欄には触らない)
    await tapCategoryRowIcon(tester, '$foodName (予算: ¥30,000)', Icons.edit);
    await saveCategoryEditor(tester, budget: 45000);

    expect(find.text('$foodName (予算: ¥45,000)'), findsOneWidget);
    expect(find.text('$foodName (予算: ¥30,000)'), findsNothing);
    _expectExpenseCategoryFields(
      await fetchFieldsByName(expensePath, foodName),
      name: foodName,
      budget: 45000,
    );
    expect(
      await fetchDocumentPathByName(expensePath, foodName),
      foodDocumentPath,
    );
    // 編集していない収入カテゴリはそのまま残る
    expect(find.text(editedSalaryName), findsOneWidget);

    // 確認ダイアログで「削除しない」を選ぶと何も消えない
    const foodRowText = '$foodName (予算: ¥45,000)';
    await tapCategoryRowIcon(tester, foodRowText, Icons.delete);
    expect(find.text('本当に「$foodName」を削除しますか？'), findsOneWidget);
    await tester.tap(find.text('削除しない'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text(foodRowText), findsOneWidget);
    expect(await countDocumentsByName(expensePath, foodName), 1);

    // 「削除する」を選ぶと支出カテゴリが消える
    await tapCategoryRowIcon(tester, foodRowText, Icons.delete);
    await tester.tap(find.text('削除する'));
    await tester.pumpAndSettle();

    // 削除後に一覧を取り直す実装は無い。行が消えるのはカテゴリの購読が削除を
    // 反映するからであり、それ自体がリアルタイム反映の検証になる
    await waitUntil(
      tester,
      () => find.text(foodRowText).evaluate().isEmpty,
      description: '削除した支出カテゴリが一覧から消えること',
    );
    expect(find.text('支出カテゴリがありません。新規追加してください'), findsOneWidget);
    await waitUntil(
      tester,
      () async => await countDocumentsByName(expensePath, foodName) == 0,
      description: '削除した支出カテゴリのドキュメントが消えること',
    );
    // 削除していない収入カテゴリは残る
    expect(find.text(editedSalaryName), findsOneWidget);
    expect(await countDocumentsByName(incomePath, editedSalaryName), 1);

    // 収入カテゴリも削除できる(収入と支出は別の削除操作になる)
    await tapCategoryRowIcon(tester, editedSalaryName, Icons.delete);
    expect(find.text('本当に「$editedSalaryName」を削除しますか？'), findsOneWidget);
    await tester.tap(find.text('削除する'));
    await tester.pumpAndSettle();

    await waitUntil(
      tester,
      () => find.text(editedSalaryName).evaluate().isEmpty,
      description: '削除した収入カテゴリが一覧から消えること',
    );
    expect(find.text('収入カテゴリがありません。新規追加してください'), findsOneWidget);
    await waitUntil(
      tester,
      () async => await countDocumentsByName(incomePath, editedSalaryName) == 0,
      description: '削除した収入カテゴリのドキュメントが消えること',
    );
  });

  testWidgets('ペアリング済みユーザーはふたりの家計簿でカテゴリを管理できるので、共有収支をカテゴリ別に整理できる', (
    tester,
  ) async {
    const sharedIncomeName = 'カテゴリ画面:共同収入';
    const editedSharedIncomeName = 'カテゴリ画面:共同家賃収入';
    const sharedExpenseName = 'カテゴリ画面:共同生活費';
    const sharedExpenseRowText = '$sharedExpenseName (予算: ¥50,000)';
    const editedSharedExpenseRowText = '$sharedExpenseName (予算: ¥60,000)';

    await tester.pumpWidget(const MyApp());
    // FIXME: ペアリング機能未作成の間は、seed済みのペアユーザーでサインインする
    await signInApp(tester, pairUser);
    await tester.pumpAndSettle();
    await switchToSharedNote(tester);

    await createIncomeCategory(tester, name: sharedIncomeName);
    await createExpenseCategory(tester, name: sharedExpenseName, budget: 50000);

    expect(find.text(sharedIncomeName), findsOneWidget);
    expect(find.text(sharedExpenseRowText), findsOneWidget);

    final notePath = await currentSharedNotePath();
    expect(notePath, startsWith('sharedNotes/'));
    final incomePath = '$notePath/incomeCategories';
    final expensePath = '$notePath/expenseCategories';
    _expectIncomeCategoryFields(
      await fetchFieldsByName(incomePath, sharedIncomeName),
      name: sharedIncomeName,
    );
    _expectExpenseCategoryFields(
      await fetchFieldsByName(expensePath, sharedExpenseName),
      name: sharedExpenseName,
      budget: 50000,
    );
    // 共有ノートを選んでいるときは、個人ノートへは書き込まない
    final personalNotePath = currentPersonalNotePath();
    expect(
      await countDocumentsByName(
        '$personalNotePath/incomeCategories',
        sharedIncomeName,
      ),
      0,
    );
    expect(
      await countDocumentsByName(
        '$personalNotePath/expenseCategories',
        sharedExpenseName,
      ),
      0,
    );

    await tapCategoryRowIcon(tester, sharedIncomeName, Icons.edit);
    await saveCategoryEditor(tester, name: editedSharedIncomeName);

    expect(find.text(editedSharedIncomeName), findsOneWidget);
    expect(find.text(sharedIncomeName), findsNothing);
    _expectIncomeCategoryFields(
      await fetchFieldsByName(incomePath, editedSharedIncomeName),
      name: editedSharedIncomeName,
    );
    expect(await countDocumentsByName(incomePath, sharedIncomeName), 0);

    await tapCategoryRowIcon(tester, sharedExpenseRowText, Icons.edit);
    await saveCategoryEditor(tester, budget: 60000);

    expect(find.text(editedSharedExpenseRowText), findsOneWidget);
    _expectExpenseCategoryFields(
      await fetchFieldsByName(expensePath, sharedExpenseName),
      name: sharedExpenseName,
      budget: 60000,
    );

    await tapCategoryRowIcon(tester, editedSharedExpenseRowText, Icons.delete);
    await tester.tap(find.text('削除する'));
    await tester.pumpAndSettle();
    await waitUntil(
      tester,
      () => find.text(editedSharedExpenseRowText).evaluate().isEmpty,
      description: '削除した共有の支出カテゴリが一覧から消えること',
    );
    await waitUntil(
      tester,
      () async =>
          await countDocumentsByName(expensePath, sharedExpenseName) == 0,
      description: '削除した共有の支出カテゴリのドキュメントが消えること',
    );

    await tapCategoryRowIcon(tester, editedSharedIncomeName, Icons.delete);
    await tester.tap(find.text('削除する'));
    await tester.pumpAndSettle();
    await waitUntil(
      tester,
      () => find.text(editedSharedIncomeName).evaluate().isEmpty,
      description: '削除した共有の収入カテゴリが一覧から消えること',
    );
    await waitUntil(
      tester,
      () async =>
          await countDocumentsByName(incomePath, editedSharedIncomeName) == 0,
      description: '削除した共有の収入カテゴリのドキュメントが消えること',
    );
  });
}

/// 収入カテゴリのドキュメントの内容を検証する。
///
/// 予算は支出カテゴリだけが持つため、収入カテゴリに`totalBudget`が無いことも見る。
void _expectIncomeCategoryFields(
  Map<String, dynamic> fields, {
  required String name,
}) {
  expect(readString(fields, 'name'), name);
  expect(readString(fields, 'type'), 'income');
  expect(fields.containsKey('totalBudget'), isFalse);
}

/// 支出カテゴリのドキュメントの内容を検証する。
void _expectExpenseCategoryFields(
  Map<String, dynamic> fields, {
  required String name,
  required int budget,
}) {
  expect(readString(fields, 'name'), name);
  expect(readString(fields, 'type'), 'expense');
  expect(readInt(fields, 'totalBudget'), budget);
}
