import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/domain/models/budget.dart';
import 'package:household_accounts/domain/models/category.dart';
import 'package:household_accounts/domain/models/category_id.dart';
import 'package:household_accounts/domain/models/category_name.dart';
import 'package:household_accounts/ui/categories/categories_screen.dart';
import 'package:household_accounts/ui/categories/categories_view_model.dart';
import 'package:household_accounts/utils/result.dart';

import '../../test-util/fake_category_repository.dart';
import '../../test-util/golden_helper.dart';

final _salary = IncomeCategory(
  id: CategoryId('salary'),
  name: CategoryName('給与'),
);
// 名前の上限ちょうどのカテゴリ。長い名前でも編集・削除アイコンが押し出されないことを見る
final _longIncome = IncomeCategory(
  id: CategoryId('long-income'),
  name: CategoryName('あ' * CategoryName.maxLength),
);
final _food = ExpenseCategory(
  id: CategoryId('food'),
  name: CategoryName('食費'),
  budget: Budget(30000),
);
final _noBudget = ExpenseCategory(
  id: CategoryId('no-budget'),
  name: CategoryName('雑費'),
  budget: Budget(0),
);
final _longExpense = ExpenseCategory(
  id: CategoryId('long-expense'),
  name: CategoryName('い' * CategoryName.maxLength),
  budget: Budget(123456789),
);

// なぜ確認ダイアログをgoldenで撮らないか:
// ダイアログは資産と共通のWidget(DeleteConfirmationDialog)であり、見た目は
// 資産一覧のgolden(properties_delete_dialog)で固定済みである。ここでは
// カテゴリ名が本文に入ることを通常のtestWidgetsで確かめる。
//
// なぜスナックバーをgoldenで確認しないか:
// 3幅ヘルパーの外側のScaffoldに出るため撮影範囲の外になる。文言は下の
// 通常のtestWidgetsで固定する。
void main() {
  group('golden', () {
    late _Fixture fixture;

    testGoldens(
      'カテゴリの一覧が未着のとき、両方のセクションにローディングが表示されること',
      goldenFileName: 'categories_loading',
      builder: () => (fixture = _buildFixture()).screen,
    );

    testGoldens(
      'どちらのカテゴリも1件も無いとき、両方のセクションに追加を促す文言が表示されること',
      goldenFileName: 'categories_empty',
      builder: () => (fixture = _buildFixture()).screen,
      expectFn: (tester) async {
        fixture.repository.incomeCategoriesController.add([]);
        fixture.repository.expenseCategoriesController.add([]);
        await tester.pumpAndSettle();
      },
    );

    testGoldens(
      '上限文字数の名前や予算0・大きな予算を含むカテゴリが届いたとき、各行に名前と予算が表示されること',
      goldenFileName: 'categories_loaded',
      builder: () => (fixture = _buildFixture()).screen,
      expectFn: (tester) async {
        fixture.repository.incomeCategoriesController.add([
          _longIncome,
          _salary,
        ]);
        fixture.repository.expenseCategoriesController.add([
          _longExpense,
          _noBudget,
          _food,
        ]);
        await tester.pumpAndSettle();
      },
    );

    testGoldens(
      '支出カテゴリの購読だけが失敗したとき、支出のセクションだけにエラーが表示され収入の一覧は表示されること',
      goldenFileName: 'categories_expense_load_failed',
      builder: () => (fixture = _buildFixture()).screen,
      expectFn: (tester) async {
        fixture.repository.incomeCategoriesController.add([_salary]);
        fixture.repository.expenseCategoriesController.addError(
          Exception('watchExpenseCategoriesエラー'),
        );
        await tester.pumpAndSettle();
      },
    );
  });

  group('表示', () {
    testWidgets('支出カテゴリが届いたとき、名前と予算が「名前 (予算: 金額)」の形で表示されること', (tester) async {
      await _pumpLoaded(tester);

      expect(find.text('食費 (予算: ¥30,000)'), findsOneWidget);
      expect(find.text('給与'), findsOneWidget);
    });
  });

  group('削除', () {
    testWidgets('削除アイコンを押したとき、カテゴリ名を含む確認ダイアログが開き、まだ削除されないこと', (tester) async {
      final fixture = await _pumpLoaded(tester);

      await _tapDeleteOf(tester, '給与');

      expect(find.text('本当に「給与」を削除しますか？'), findsOneWidget);
      expect(fixture.repository.deleteIncomeCategoryCalls, isEmpty);
    });

    testWidgets('確認ダイアログで削除しないを選んだとき、ダイアログが閉じ削除されないこと', (tester) async {
      final fixture = await _pumpLoaded(tester);
      await _tapDeleteOf(tester, '給与');

      await tester.tap(find.text('削除しない'));
      await tester.pumpAndSettle();

      expect(find.text('本当に「給与」を削除しますか？'), findsNothing);
      expect(fixture.repository.deleteIncomeCategoryCalls, isEmpty);
      expect(fixture.repository.deleteExpenseCategoryCalls, isEmpty);
    });

    testWidgets('収入カテゴリの確認ダイアログで削除するを選んだとき、収入カテゴリとして削除されること', (tester) async {
      final fixture = await _pumpLoaded(tester);
      await _tapDeleteOf(tester, '給与');

      await tester.tap(find.text('削除する'));
      await tester.pumpAndSettle();

      expect(find.text('本当に「給与」を削除しますか？'), findsNothing);
      expect(fixture.repository.deleteIncomeCategoryCalls, [_salary.id]);
      expect(fixture.repository.deleteExpenseCategoryCalls, isEmpty);
    });

    testWidgets('支出カテゴリの確認ダイアログで削除するを選んだとき、支出カテゴリとして削除されること', (tester) async {
      final fixture = await _pumpLoaded(tester);
      await _tapDeleteOf(tester, '食費 (予算: ¥30,000)');

      // 本文には予算を含めず、カテゴリ名だけを出す
      expect(find.text('本当に「食費」を削除しますか？'), findsOneWidget);
      await tester.tap(find.text('削除する'));
      await tester.pumpAndSettle();

      expect(fixture.repository.deleteExpenseCategoryCalls, [_food.id]);
      expect(fixture.repository.deleteIncomeCategoryCalls, isEmpty);
    });

    testWidgets('収入カテゴリの削除に失敗したとき、スナックバーで失敗が伝えられること', (tester) async {
      final fixture = await _pumpLoaded(tester);
      fixture.repository.deleteIncomeCategoryResult = Result.error(
        Exception('deleteエラー'),
      );
      await _tapDeleteOf(tester, '給与');

      await tester.tap(find.text('削除する'));
      await tester.pumpAndSettle();

      expect(find.text('収入カテゴリの削除に失敗しました'), findsOneWidget);
    });

    testWidgets('支出カテゴリの削除に失敗したとき、スナックバーで失敗が伝えられること', (tester) async {
      final fixture = await _pumpLoaded(tester);
      fixture.repository.deleteExpenseCategoryResult = Result.error(
        Exception('deleteエラー'),
      );
      await _tapDeleteOf(tester, '食費 (予算: ¥30,000)');

      await tester.tap(find.text('削除する'));
      await tester.pumpAndSettle();

      expect(find.text('支出カテゴリの削除に失敗しました'), findsOneWidget);
    });
  });
}

class _Fixture {
  _Fixture({required this.screen, required this.repository});

  final CategoriesScreen screen;
  final FakeCategoryRepository repository;
}

_Fixture _buildFixture() {
  final repository = FakeCategoryRepository();
  return _Fixture(
    screen: CategoriesScreen(
      viewModel: CategoriesViewModel(categoryRepository: repository),
    ),
    repository: repository,
  );
}

/// 収入カテゴリ1件・支出カテゴリ1件が届いた一覧を表示する。
///
/// 一覧はシェルの本体として表示されScaffoldを持たないため、スナックバーの
/// 表示先となるScaffoldで包む(シェルのScaffoldの代わり)。
Future<_Fixture> _pumpLoaded(WidgetTester tester) async {
  final fixture = _buildFixture();
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: fixture.screen)));
  fixture.repository.incomeCategoriesController.add([_salary]);
  fixture.repository.expenseCategoriesController.add([_food]);
  await tester.pumpAndSettle();
  return fixture;
}

/// 文言[label]の行の削除アイコンを押し、確認ダイアログが開くまで待つ。
Future<void> _tapDeleteOf(WidgetTester tester, String label) async {
  final row = find.ancestor(of: find.text(label), matching: find.byType(Row));
  await tester.tap(
    find.descendant(of: row.first, matching: find.byIcon(Icons.delete)),
  );
  await tester.pumpAndSettle();
}
