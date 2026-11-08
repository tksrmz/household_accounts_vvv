import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/ui/core/formatter.dart';
import 'package:household_accounts/domain/models/fiscal_month.dart';
import 'package:household_accounts/main.dart';
import 'package:household_accounts/ui/budget/widgets/budget_row.dart';
import 'package:household_accounts/ui/budget/widgets/period_header.dart';

import 'util/category_operations.dart';
import 'util/property_operations.dart';
import 'util/record_seeding.dart';
import 'util/sign_up.dart';
import 'util/ui_operations.dart';

/// 予算画面(暦月・月度の切り替えと期間送り、カテゴリ別の予算の消化状況)の
/// 受け入れテスト。
///
/// integrationテストは[MyApp]をそのままpumpしており、予算画面が使う「今日」
/// ([DateTime.now])をテスト側から差し替える経路が無い。そのため期待値は
/// 実行時の今日から相対的に求める(月替わり・年またぎでも壊れないよう、
/// 月の前後は[DateTime]の正規化で計算する)。
///
/// 支出はREST APIで投入する([createExpenseRecord])。月度の境界日は実行日に
/// よっては未来日付になり、記録入力画面からは入力できないため。
///
/// カテゴリ名はこのファイル固有の名前にする。他のfeatureテストが作った
/// カテゴリと取り違えないため。
Future<void> budgetFeature() async {
  testWidgets(
    'ユーザーは予算タブで暦月・月度（16日〜翌月15日）ごとのカテゴリ別支出を確認できるので、給与サイクルに合わせて予算を管理できる',
    (tester) async {
      const categoryName = '予算画面:食費';
      const propertyName = '予算画面:現金';
      const budget = 30000;

      final today = DateTime.now();
      final thisMonth = DateTime(today.year, today.month);
      final previousMonth = DateTime(today.year, today.month - 1);
      final fiscalMonth = FiscalMonth.containing(today);

      // 今日が属する月度の境界の4日付(開始の前日・開始日・終了の前日(15日)・
      // 終了日(=次の月度の開始日))に支出を1件ずつ置く。金額は、どの組み合わせで
      // 合計しても別の組み合わせと同じ値にならないよう2のべき乗にする
      final fiscalStart = DateTime(fiscalMonth.year, fiscalMonth.month - 1, 16);
      final fiscalEnd = DateTime(fiscalMonth.year, fiscalMonth.month, 16);
      final boundaryRecords = [
        (date: _addDays(fiscalStart, -1), amount: 1000, note: '月度の開始の前日(前の月度)'),
        (date: fiscalStart, amount: 2000, note: '月度の開始日'),
        (date: _addDays(fiscalEnd, -1), amount: 4000, note: '月度の終了の前日(15日)'),
        (date: fiscalEnd, amount: 8000, note: '月度の終了日(次の月度)'),
      ];

      await tester.pumpWidget(const MyApp());
      await signUpApp(tester);
      await tester.pumpAndSettle();

      await createExpenseCategory(tester, name: categoryName, budget: budget);
      await createProperty(tester, name: propertyName, amount: 100000);
      for (final record in boundaryRecords) {
        await createExpenseRecord(
          tester,
          date: record.date,
          amount: record.amount,
          categoryName: categoryName,
          propertyName: propertyName,
          note: record.note,
        );
      }

      // 暦月の集計に入るのは、境界の4件のうち今月に属するもの。どれが今月に
      // 属するかは実行日に依存する(今日が1〜15日なら終了側の2件、16日以降なら
      // 月度が翌月度になり開始側の2件)ため、投入した日付から求める
      int totalIn(DateTime month) => boundaryRecords
          .where(
            (r) => r.date.year == month.year && r.date.month == month.month,
          )
          .fold(0, (total, r) => total + r.amount);

      // 初期表示は今日の暦月
      await openTab(tester, '予算');
      await _waitForBudgetRow(
        tester,
        categoryName,
        spent: totalIn(thisMonth),
        budget: budget,
      );
      expect(find.text(_calendarMonthLabel(thisMonth)), findsOneWidget);
      // 今日の暦月より先へは進めない
      expect(_isArrowEnabled(tester, Icons.arrow_right), isFalse);
      await tester.tap(_arrow(Icons.arrow_right));
      await tester.pumpAndSettle();
      expect(find.text(_calendarMonthLabel(thisMonth)), findsOneWidget);

      // 前の月へ戻ると、その月の支出が集計される(今日が16日以降なら、前の月には
      // 支出が無く¥0になる)
      await tester.tap(_arrow(Icons.arrow_left));
      await tester.pumpAndSettle();
      expect(find.text(_calendarMonthLabel(previousMonth)), findsOneWidget);
      await _waitForBudgetRow(
        tester,
        categoryName,
        spent: totalIn(previousMonth),
        budget: budget,
      );
      // 過去の月からは次の月へ進める
      expect(_isArrowEnabled(tester, Icons.arrow_right), isTrue);

      await tester.tap(_arrow(Icons.arrow_right));
      await tester.pumpAndSettle();
      expect(find.text(_calendarMonthLabel(thisMonth)), findsOneWidget);
      await _waitForBudgetRow(
        tester,
        categoryName,
        spent: totalIn(thisMonth),
        budget: budget,
      );
      expect(_isArrowEnabled(tester, Icons.arrow_right), isFalse);

      // 「月度」に切り替えると、今日が属する月度を表示する
      await tester.tap(find.text('月度'));
      await tester.pumpAndSettle();
      expect(find.text(_fiscalMonthLabel(fiscalMonth)), findsOneWidget);
      // 境界外の2件(開始の前日・終了日)は含まれず、境界内の2件
      // (開始日・終了の前日、2000+4000)だけが集計される
      await _waitForBudgetRow(
        tester,
        categoryName,
        spent: 6000,
        budget: budget,
      );
      // 今日が属する月度より先へは進めない
      expect(_isArrowEnabled(tester, Icons.arrow_right), isFalse);
    },
  );

  testWidgets('ユーザーはカテゴリを削除しても、そのカテゴリの支出を予算タブの「削除済み」で確認できるので、支出の合計を見失わない', (
    tester,
  ) async {
    const deletedCategoryName = '予算画面:旅行';
    const deletedCategoryBudget = 30000;
    const keptCategoryName = '予算画面:日用品';
    const keptCategoryBudget = 20000;
    const propertyName = '予算画面:財布';

    final now = DateTime.now();
    // 今日の0時。今日の暦月に必ず属する
    final today = DateTime(now.year, now.month, now.day);

    await tester.pumpWidget(const MyApp());
    await signUpApp(tester);
    await tester.pumpAndSettle();

    await createExpenseCategory(
      tester,
      name: deletedCategoryName,
      budget: deletedCategoryBudget,
    );
    await createExpenseCategory(
      tester,
      name: keptCategoryName,
      budget: keptCategoryBudget,
    );
    await createProperty(tester, name: propertyName, amount: 100000);
    final records = [
      (categoryName: deletedCategoryName, amount: 3000),
      (categoryName: deletedCategoryName, amount: 5000),
      (categoryName: keptCategoryName, amount: 1000),
    ];
    for (final record in records) {
      await createExpenseRecord(
        tester,
        date: today,
        amount: record.amount,
        categoryName: record.categoryName,
        propertyName: propertyName,
        note: '予算画面:削除済みの確認',
      );
    }

    // 削除する前は、それぞれのカテゴリの行に集計される
    await openTab(tester, '予算');
    await _waitForBudgetRow(
      tester,
      deletedCategoryName,
      spent: 8000,
      budget: deletedCategoryBudget,
    );
    _expectBudgetRow(keptCategoryName, spent: 1000, budget: keptCategoryBudget);
    expect(_budgetRow('削除済み'), findsNothing);

    // カテゴリ画面で支出カテゴリを1件削除する
    await openTab(tester, 'カテゴリ');
    final deletedRowText =
        '$deletedCategoryName (予算: '
        '${Formatter.simpleCurrency(deletedCategoryBudget)})';
    await tapCategoryRowIcon(tester, deletedRowText, Icons.delete);
    await tester.tap(find.text('削除する'));
    await tester.pumpAndSettle();
    await waitUntil(
      tester,
      () => find.text(deletedRowText).evaluate().isEmpty,
      description: '削除した支出カテゴリがカテゴリ一覧から消えること',
    );

    // 予算タブでは、削除したカテゴリの行が消え、その支出は末尾の「削除済み」行
    // (予算¥0)にまとめて出る
    await openTab(tester, '予算');
    await _waitForBudgetRow(tester, '削除済み', spent: 8000, budget: 0);
    expect(_budgetRow(deletedCategoryName), findsNothing);
    _expectBudgetRow(keptCategoryName, spent: 1000, budget: keptCategoryBudget);
    expect(
      tester.getTopLeft(_budgetRow('削除済み')).dy,
      greaterThan(tester.getTopLeft(_budgetRow(keptCategoryName)).dy),
    );
  });
}

/// [date]の[days]日後(負なら前)の0時。
///
/// [Duration]で日数を足し引きすると夏時間のある地域で日付がずれうるため、
/// 日の値をずらした[DateTime]で求める。
DateTime _addDays(DateTime date, int days) =>
    DateTime(date.year, date.month, date.day + days);

/// 暦月[month]のラベル(「2026年7月（7/1〜7/31）」)。
String _calendarMonthLabel(DateTime month) {
  // 翌月の0日=その月の末日
  final lastDay = DateTime(month.year, month.month + 1, 0).day;
  return '${month.year}年${month.month}月'
      '（${month.month}/1〜${month.month}/$lastDay）';
}

/// 月度[fiscalMonth]のラベル(「2026年7月度（6/16〜7/15）」)。
String _fiscalMonthLabel(FiscalMonth fiscalMonth) {
  final previousMonth = DateTime(fiscalMonth.year, fiscalMonth.month - 1);
  return '${fiscalMonth.year}年${fiscalMonth.month}月度'
      '（${previousMonth.month}/16〜${fiscalMonth.month}/15）';
}

/// 期間ヘッダの矢印([Icons.arrow_left]/[Icons.arrow_right])。
Finder _arrow(IconData icon) => find.descendant(
  of: find.byType(PeriodHeader),
  matching: find.widgetWithIcon(IconButton, icon),
);

/// 期間ヘッダの矢印[icon]が押せる状態か。
bool _isArrowEnabled(WidgetTester tester, IconData icon) =>
    tester.widget<IconButton>(_arrow(icon)).onPressed != null;

/// カテゴリ名[name]を表示している予算の行。
Finder _budgetRow(String name) =>
    find.ancestor(of: find.text(name), matching: find.byType(BudgetRow));

/// 予算の行に表示される「支出 / 予算」の金額(「¥12,000 / ¥30,000」)。
String _amountText({required int spent, required int budget}) =>
    '${Formatter.simpleCurrency(spent)} / ${Formatter.simpleCurrency(budget)}';

/// カテゴリ名[name]の行が1つあり、「[spent] / [budget]」を表示していることを
/// 確かめる。
void _expectBudgetRow(String name, {required int spent, required int budget}) {
  final row = _budgetRow(name);
  expect(row, findsOneWidget);
  expect(
    find.descendant(
      of: row,
      matching: find.text(_amountText(spent: spent, budget: budget)),
    ),
    findsOneWidget,
  );
}

/// カテゴリ名[name]の行が「[spent] / [budget]」を表示するまで待ち、その行が
/// 1つだけであることを確かめる。
///
/// 期間やカテゴリを変えた直後は、Firestoreの購読から新しい値が届くまで
/// 古い集計やローディングが表示される。
Future<void> _waitForBudgetRow(
  WidgetTester tester,
  String name, {
  required int spent,
  required int budget,
}) async {
  final amountText = _amountText(spent: spent, budget: budget);
  await waitUntil(
    tester,
    () => find
        .descendant(of: _budgetRow(name), matching: find.text(amountText))
        .evaluate()
        .isNotEmpty,
    description: '予算の行「$name」が「$amountText」を表示すること',
  );
  _expectBudgetRow(name, spent: spent, budget: budget);
}
