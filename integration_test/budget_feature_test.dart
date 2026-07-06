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
/// - 暦月表示（今月1日〜来月1日未満）に含まれるのは「end前日(15日)」
///   「end当日(16日)」の2件 → 合計 4000+8000=12000円
/// - 月度表示（begin〜end）に含まれるのは「begin当日」「end前日(15日)」
///   の2件 → 合計 2000+4000=6000円
/// - 「begin前日」「end当日」はどちらの表示にも含まれない
///   （AC-002: 境界外レコードの除外）
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
      // (前月度に属する: 月度・暦月どちらの集計にも含まれない)
      await createExpenseRecord(
        tester,
        date: beginPrevDay,
        amount: 1000,
        categoryName: categoryName,
        propertyName: propertyName,
        note: '月度begin前日(前月度)',
      );
      // (月度の開始日: 月度の集計に含まれる。暦月には含まれない)
      await createExpenseRecord(
        tester,
        date: beginDay,
        amount: 2000,
        categoryName: categoryName,
        propertyName: propertyName,
        note: '月度begin当日',
      );
      // (月度の終了前日=15日: 月度・暦月どちらの集計にも含まれる)
      await createExpenseRecord(
        tester,
        date: endPrevDay,
        amount: 4000,
        categoryName: categoryName,
        propertyName: propertyName,
        note: '月度end前日(15日)',
      );
      // (月度の終了日=次月度の開始日: 月度の集計には含まれない。暦月には含まれる)
      await createExpenseRecord(
        tester,
        date: endDay,
        amount: 8000,
        categoryName: categoryName,
        propertyName: propertyName,
        note: '月度end当日(翌月度)',
      );

      // 予算タブへ移動する
      await tester.tap(find.text('予算'));
      await tester.pumpAndSettle();

      // AC-008: 暦月表示（デフォルト）では、今月に属する2件
      // (15日・16日、合計4000+8000=12000円)のみが集計される
      expect(find.text('$categoryName'), findsOneWidget);
      expect(find.text('12000 / 30000円'), findsOneWidget);

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
