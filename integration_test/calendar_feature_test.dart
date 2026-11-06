import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/main.dart';

import 'util/firestore_probe.dart';
import 'util/property_operations.dart';
import 'util/record_entry_operations.dart';
import 'util/record_seeding.dart';
import 'util/seed_record_dates.dart';
import 'util/sign_in.dart';
import 'util/sign_up.dart';
import 'util/ui_operations.dart';

/// カレンダー(月次カレンダーと日次明細)の受け入れテスト。
///
/// 削除の検証は、行が消えることだけでなく資産残高の復元とドキュメントの消滅も
/// REST APIで直接確認する。表示だけを見ていると、残高の打ち消し漏れや、
/// 誤ったノートのドキュメントを消していることを見逃すため。
///
/// 削除対象は**このテストがUIで作成したレコード**に限る。seedレコードは
/// 他のfeatureテスト(ダッシュボード・予算)が件数と金額に依存しているため、
/// 消すとそれらを壊してしまう。
Future<void> calendarFeature() async {
  testWidgets('ユーザーはカレンダーで日ごとの収支を確認できるので、いつお金が動いたかを把握できる', (tester) async {
    // seedレコードの日付を実行時の「今月」の月境界へ揃える
    // (カレンダーは端末ローカルTZの暦月を表示するため。詳細はヘルパーのdoc参照)
    await alignSeedRecordDatesToCurrentMonth();

    await tester.pumpWidget(const MyApp());
    await signInApp(tester, singleUser);
    await tester.pumpAndSettle();

    final now = DateTime.now();
    // 翌月0日は当月末日を表す(DateTimeの正規化を日数の算出に利用する)
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;

    await openTab(tester, 'カレンダー');
    expect(find.text('${now.year}/${now.month}'), findsOneWidget);

    // seedの月初レコード(収入¥1・支出¥2)と月末レコード(収入¥1・支出¥1)が
    // それぞれの日セルに分かれて表示される。振替のseedは無いためどちらも¥0
    expect(_dayCellAmounts(tester, 1), ['¥1', '¥2', '¥0']);
    expect(_dayCellAmounts(tester, lastDayOfMonth), ['¥1', '¥1', '¥0']);

    // 前月末23:59:59・翌月初00:00のseedレコード(¥100/¥1,000)は今月に含めない
    expect(find.text('¥100'), findsNothing);
    expect(find.text('¥1,000'), findsNothing);

    // 未来の月は集計する対象がないため進めない
    expect(_monthArrowButton(tester, Icons.arrow_right).onPressed, isNull);

    // 日セルをタップすると、その日の明細がボトムナビを覆って開く
    await _openDay(tester, 1);
    expect(find.text('${now.year}/${now.month}/1'), findsOneWidget);
    // seedレコードの参照先カテゴリは存在しないため、名前は削除済み表示になる。
    // 収入と支出の2件が同じメモを持つため同じ文言が2行に出る
    expect(find.text('削除済み@date下限値'), findsNWidgets(2));
    // 収入だけが残高を増やすため符号が付く
    expect(find.text('+¥1'), findsOneWidget);
    expect(find.text('¥2'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('${now.year}/${now.month}'), findsOneWidget);

    // 前の月へ切り替えると購読が張り替わり、今月の集計から外れていた
    // 前月末のseedレコード(収入¥100・支出¥100)が現れる
    await tester.tap(find.byIcon(Icons.arrow_left));
    await tester.pumpAndSettle();
    final previousMonthEnd = DateTime(now.year, now.month, 0);
    expect(
      find.text('${previousMonthEnd.year}/${previousMonthEnd.month}'),
      findsOneWidget,
    );
    expect(_dayCellAmounts(tester, previousMonthEnd.day), [
      '¥100',
      '¥100',
      '¥0',
    ]);
  });

  testWidgets('ユーザーは自分の家計簿の記録をカレンダーから削除できるので、誤って登録した記録を取り消せる', (tester) async {
    const categoryName = 'カレンダー収入';
    const propertyName = 'カレンダー財布';
    const note = 'カレンダー削除:臨時収入';
    const leadingText = '$categoryName@$note';
    const amount = 3000;

    _ignoreFirestoreTransactionTeardownError();

    await tester.pumpWidget(const MyApp());
    await signUpApp(tester);
    await tester.pumpAndSettle();

    await createIncomeCategory(tester, name: categoryName);
    await createProperty(tester, name: propertyName, amount: 10000);

    final notePath = currentPersonalNotePath();
    final balanceBeforeCreating = await fetchPropertyAmount(
      notePath,
      propertyName,
    );

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
    expect(
      await fetchPropertyAmount(notePath, propertyName),
      balanceBeforeCreating + amount,
    );

    // 記録の日付は当日で入るため、当日の日セルを開けば必ず明細に現れる
    final today = DateTime.now();
    await openTab(tester, 'カレンダー');
    await _openDay(tester, today.day);
    expect(
      find.text('${today.year}/${today.month}/${today.day}'),
      findsOneWidget,
    );
    expect(find.text(leadingText), findsOneWidget);
    expect(
      find.descendant(of: _rowOf(leadingText), matching: find.text('+¥3,000')),
      findsOneWidget,
    );

    await _deleteRow(tester, leadingText);

    // 削除後に一覧を取り直す実装は無い。行が消えるのはレコードの購読が
    // 削除を反映するからであり、それ自体がリアルタイム反映の検証になる
    await waitUntil(
      tester,
      () => find.text(leadingText).evaluate().isEmpty,
      description: '削除した行が明細から消えること',
    );
    await waitUntil(
      tester,
      () async =>
          await fetchPropertyAmount(notePath, propertyName) ==
          balanceBeforeCreating,
      description: '資産残高が記録の作成前へ戻ること',
    );
    expect(await countRecordsByNote(notePath, 'incomes', note), 0);
  });

  testWidgets('ペアリング済みユーザーはふたりの家計簿の振替をカレンダーから削除できるので、共有資産の残高を正しく保てる', (
    tester,
  ) async {
    const fromPropertyName = 'カレンダー共同A';
    const toPropertyName = 'カレンダー共同B';
    const note = 'カレンダー削除:共有振替';
    const leadingText = '$fromPropertyName→$toPropertyName';
    const amount = 30000;

    _ignoreFirestoreTransactionTeardownError();

    await tester.pumpWidget(const MyApp());
    // FIXME: ペアリング機能未作成の間は、seed済みのペアユーザーでサインインする
    await signInApp(tester, pairUser);
    await tester.pumpAndSettle();
    await switchToSharedNote(tester);

    await createProperty(tester, name: fromPropertyName, amount: 80000);
    await createProperty(tester, name: toPropertyName, amount: 20000);

    final notePath = await currentSharedNotePath();
    expect(notePath, startsWith('sharedNotes/'));
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

    final today = DateTime.now();
    await openTab(tester, 'カレンダー');
    await _openDay(tester, today.day);

    // 旧実装は共有ノートの振替を個人ノートのパスで読み書きしていた。
    // 共有ノートで作成した振替が明細に現れること自体が、読み取りも
    // sharedNotes配下を見ている証拠になる
    expect(find.text(leadingText), findsOneWidget);
    expect(
      find.descendant(of: _rowOf(leadingText), matching: find.text('¥30,000')),
      findsOneWidget,
    );

    await _deleteRow(tester, leadingText);

    await waitUntil(
      tester,
      () => find.text(leadingText).evaluate().isEmpty,
      description: '削除した行が明細から消えること',
    );
    await waitUntil(
      tester,
      () async =>
          await fetchPropertyAmount(notePath, fromPropertyName) ==
              fromBalanceBefore &&
          await fetchPropertyAmount(notePath, toPropertyName) ==
              toBalanceBefore,
      description: '振替元・振替先の残高がどちらも記録の作成前へ戻ること',
    );
    expect(await countRecordsByNote(notePath, 'transfers', note), 0);
  });
}

/// レコード削除のトランザクション終了時にfirebase_firestoreプラグインが報告する
/// 既知の例外を、実行中のテストの間だけ無視する。
///
/// `runTransaction`はトランザクション完了時にトランザクション専用の
/// EventChannelの購読をcancelするが、ネイティブ側は完了と同時にそのチャネルの
/// ハンドラを外すため、cancelがMissingPluginExceptionになる
/// (cloud_firestore 6.8.0)。プラグイン内部の後始末の問題であり、
/// トランザクション自体は成功している。flutter_testはFlutterErrorへ報告された
/// 例外をすべてテスト失敗として扱うため、この例外だけを落として他は素通しする。
void _ignoreFirestoreTransactionTeardownError() {
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    final exception = details.exception;
    if (exception is MissingPluginException &&
        (exception.message ?? '').contains(
          'plugins.flutter.io/firebase_firestore/transaction/',
        )) {
      return;
    }
    previous?.call(details);
  };
  addTearDown(() => FlutterError.onError = previous);
}

/// 月次カレンダーの[day]の日セルを開く。
Future<void> _openDay(WidgetTester tester, int day) async {
  final dayNumber = find.text('$day');
  await tester.ensureVisible(dayNumber);
  await tester.pumpAndSettle();
  await tester.tap(dayNumber);
  await tester.pumpAndSettle();
}

/// [day]の日セルに表示されている収入・支出・振替の金額。
///
/// 日セルは日番号と3つの金額をこの順に並べるため、先頭の日番号を除いた
/// 残りが[収入, 支出, 振替]になる。
List<String> _dayCellAmounts(WidgetTester tester, int day) {
  final cell = find
      .ancestor(of: find.text('$day'), matching: find.byType(GestureDetector))
      .first;
  return tester
      .widgetList<Text>(find.descendant(of: cell, matching: find.byType(Text)))
      .map((text) => text.data!)
      .skip(1)
      .toList(growable: false);
}

/// 月を切り替える矢印([icon]は[Icons.arrow_left]/[Icons.arrow_right])。
///
/// 押下可能かどうかを`onPressed`で確かめるためにボタン本体を取り出す。
IconButton _monthArrowButton(WidgetTester tester, IconData icon) =>
    tester.widget<IconButton>(
      find
          .ancestor(of: find.byIcon(icon), matching: find.byType(IconButton))
          .first,
    );

/// 日次明細で、先頭に[leadingText]を表示している行。
Finder _rowOf(String leadingText) =>
    find.ancestor(of: find.text(leadingText), matching: find.byType(Row)).first;

/// 日次明細で、先頭に[leadingText]を表示している行の削除アイコンを押す。
Future<void> _deleteRow(WidgetTester tester, String leadingText) async {
  final deleteButton = find.descendant(
    of: _rowOf(leadingText),
    matching: find.byIcon(Icons.delete),
  );
  await tester.ensureVisible(deleteButton);
  await tester.pumpAndSettle();
  await tester.tap(deleteButton);
  await tester.pumpAndSettle();
}
