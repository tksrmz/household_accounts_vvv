import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/main.dart';
import 'package:household_accounts/presentation/util/custom_cycle.dart';

import 'util/record_seeding.dart';
import 'util/sign_up.dart';

/// 予算タブの「暦月⇔月度」切替機能に関する受け入れテスト。
///
/// テストデータの戦略（design.md セクション3参照）:
/// 「今日」を[DateTime.now]で固定できないため（[BudgetViewerPage]は
/// 実行時の[DateTime.now]をデフォルトで使う。integrationテストは
/// [MyApp]をそのままpumpしており、テスト側からその関数を差し替える
/// 経路が無い）、実行時の「今日」から相対的に月度の境界日を算出して
/// seedする。
///
/// 今日が属する月度を CustomCycle.containing(today) とし、
/// - begin        = 前月16日（月度の開始・含む）
/// - end          = 当月16日（月度の終了・含まない）
/// の4点（begin前日・begin当日・end前日(15日)・end当日）にそれぞれ
/// 異なる金額の支出レコードを配置する。金額は合計しても他の組み合わせと
/// 混同しないよう2のべき乗（1000・2000・4000・8000）にしてある。
///
/// 期待される集計結果:
/// - 月度表示（begin〜end）に含まれるのは「begin当日」「end前日(15日)」
///   の2件 → 合計 2000+4000=6000円（実行日によらず一定）
/// - 「begin前日」「end当日」はどちらの表示にも含まれない
///   （AC-002: 境界外レコードの除外）
/// - 暦月表示（今月1日〜来月1日未満）に含まれるレコードは実行日に依存する。
///   今日が月の前半（1〜15日）なら月度のend側2件（4000+8000=12000円）、
///   後半（16日〜末日）なら月度は翌月度になりbegin側2件（1000+2000=3000円）
///   が今月に属するため、期待値はseedしたレコードの日付から動的に算出する
Future<void> budgetFeature() async {
  testWidgets(
    'ユーザーは予算タブで月度（16日〜翌月15日）のカテゴリ別支出を確認できるので、給与サイクルに合わせて予算を管理できる',
    (tester) async {
      final today = DateTime.now();
      final cycle = CustomCycle.containing(today);
      final beginPrevDay = cycle.begin.subtract(const Duration(days: 1));
      final beginDay = cycle.begin;
      final endPrevDay = cycle.end.subtract(const Duration(days: 1));
      final endDay = cycle.end;

      const categoryName = '食費';
      const propertyName = '現金';

      await tester.pumpWidget(const MyApp());
      await signUpApp(tester);

      // Wait for loading to finish
      await tester.pumpAndSettle();

      // 事前準備: 予算付きの支出カテゴリと資産を作成する
      await createExpenseCategory(tester, name: categoryName, budget: 30000);
      await createProperty(tester, name: propertyName, amount: 100000);

      // 境界日レコードを投入する
      // - begin前日: 前月度に属する。月度の集計に含まれない
      // - begin当日: 月度の集計に含まれる
      // - end前日(15日): 月度の集計に含まれる
      // - end当日(=次月度の開始日): 月度の集計に含まれない
      final boundaryRecords = [
        (date: beginPrevDay, amount: 1000, note: '月度begin前日(前月度)'),
        (date: beginDay, amount: 2000, note: '月度begin当日'),
        (date: endPrevDay, amount: 4000, note: '月度end前日(15日)'),
        (date: endDay, amount: 8000, note: '月度end当日(翌月度)'),
      ];
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

      // 予算タブへ移動する
      await tester.tap(find.text('予算'));
      await tester.pumpAndSettle();

      // AC-008: 暦月表示（デフォルト）では、今月に属するレコードのみが
      // 集計される。どのレコードが今月に属するかは実行日に依存するため
      // （今日が前半ならend側の12000円、後半ならbegin側の3000円）、
      // 期待値はseedしたレコードの日付から動的に算出する
      final calendarMonthTotal = boundaryRecords
          .where(
              (r) => r.date.year == today.year && r.date.month == today.month)
          .fold<int>(0, (total, r) => total + r.amount);
      expect(find.text('$categoryName'), findsOneWidget);
      expect(find.text('$calendarMonthTotal / 30000円'), findsOneWidget);

      // 「月度」に切替える
      await tester.tap(find.text('月度'));
      await tester.pumpAndSettle();

      // 月度ラベル(「YYYY年N月度（M/16〜M/15）」)が表示される
      expect(
        find.text(
          '${cycle.year}年${cycle.month}月度'
          '（${cycle.begin.month}/${cycle.begin.day}〜'
          '${endPrevDay.month}/${endPrevDay.day}）',
        ),
        findsOneWidget,
      );

      // AC-002: 境界外の2件(begin前日・end当日)は含まれず、
      // 境界内の2件(begin当日・end前日、合計2000+4000=6000円)のみが集計される
      expect(find.text('6000 / 30000円'), findsOneWidget);
    },
  );
}
