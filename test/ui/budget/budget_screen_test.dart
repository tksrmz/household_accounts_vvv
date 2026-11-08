import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/domain/models/amount.dart';
import 'package:household_accounts/domain/models/budget.dart';
import 'package:household_accounts/domain/models/category.dart';
import 'package:household_accounts/domain/models/category_id.dart';
import 'package:household_accounts/domain/models/category_name.dart';
import 'package:household_accounts/domain/models/property_id.dart';
import 'package:household_accounts/domain/models/record.dart';
import 'package:household_accounts/domain/models/record_date.dart';
import 'package:household_accounts/domain/models/record_id.dart';
import 'package:household_accounts/domain/models/record_note.dart';
import 'package:household_accounts/ui/budget/budget_screen.dart';
import 'package:household_accounts/ui/budget/budget_view_model.dart';

import '../../test-util/fake_category_repository.dart';
import '../../test-util/fake_record_repository.dart';
import '../../test-util/golden_helper.dart';

// 「今日」をテストから固定し、表示する期間と矢印の押下可否を実行日に
// 左右されないようにする
final _today = DateTime(2026, 7, 10);

final _food = _category('food', '食費', 30000);
final _transport = _category('transport', '交通費', 5000);
final _hobby = _category('hobby', '趣味', 10000);
final _gift = _category('gift', '交際費', 0);
final _misc = _category('misc', '雑費', 0);
// 名前の上限ちょうどのカテゴリ。長い名前でも金額が押し出されないことを見る
final _long = _category('long', 'あ' * CategoryName.maxLength, 123456789);

void main() {
  group('golden', () {
    late _Fixture fixture;

    testGoldens(
      '支出カテゴリとレコードが未着のとき、期間の切り替えとローディングが表示されること',
      goldenFileName: 'budget_loading',
      builder: () => (fixture = _buildFixture()).screen,
    );

    testGoldens(
      '購読が失敗したとき、期間の切り替えとエラーメッセージが表示されること',
      goldenFileName: 'budget_load_failed',
      builder: () => (fixture = _buildFixture()).screen,
      expectFn: (tester) async {
        fixture.records.recordsController.addError(Exception('watchPeriodエラー'));
        await tester.pumpAndSettle();
      },
    );

    testGoldens(
      '支出カテゴリが1件も無いとき、空の一覧が表示されること',
      goldenFileName: 'budget_no_categories',
      builder: () => (fixture = _buildFixture()).screen,
      expectFn: (tester) async {
        await _emit(tester, fixture, categories: [], records: []);
      },
    );

    testGoldens(
      '前の月を表示しているとき、支出0・予算ちょうど・予算超過・予算0・上限文字数の名前・大きな金額の各行と、押下できる右矢印が表示されること',
      goldenFileName: 'budget_loaded',
      builder: () => (fixture = _buildFixture()).screen,
      expectFn: (tester) async {
        fixture.viewModel.showPrevious();
        await _emit(
          tester,
          fixture,
          categories: [_food, _transport, _hobby, _gift, _misc, _long],
          records: [
            _expense('food', 42000),
            _expense('transport', 5000),
            _expense('gift', 3000),
            _expense('long', 98765432),
          ],
        );
      },
    );

    testGoldens(
      '削除されたカテゴリを参照する支出があるとき、一覧の末尾に「削除済み」の行が表示されること',
      goldenFileName: 'budget_deleted_category',
      builder: () => (fixture = _buildFixture()).screen,
      expectFn: (tester) async {
        await _emit(
          tester,
          fixture,
          categories: [_food],
          records: [_expense('food', 12000), _expense('deleted', 3000)],
        );
      },
    );

    testGoldens(
      '月度で今日が属する月度を表示しているとき、月度のラベルと押下できない右矢印が表示されること',
      goldenFileName: 'budget_fiscal_month',
      builder: () => (fixture = _buildFixture()).screen,
      expectFn: (tester) async {
        fixture.viewModel.selectMode(BudgetPeriodMode.fiscalMonth);
        await _emit(
          tester,
          fixture,
          categories: [_food],
          records: [_expense('food', 12000)],
        );
      },
    );
  });

  group('期間', () {
    testWidgets('暦月で表示しているとき、年月と1日〜末日のラベルが表示されること', (tester) async {
      await _pump(tester);

      expect(find.text('2026年7月（7/1〜7/31）'), findsOneWidget);
    });

    testWidgets('月度を押したとき、今日が属する月度のラベルに変わること', (tester) async {
      final fixture = await _pump(tester);

      await tester.tap(find.text('月度'));
      await tester.pump();

      expect(fixture.viewModel.mode, BudgetPeriodMode.fiscalMonth);
      expect(find.text('2026年7月度（6/16〜7/15）'), findsOneWidget);
    });

    testWidgets('月度から暦月を押したとき、暦月のラベルに戻ること', (tester) async {
      final fixture = await _pump(tester);
      await tester.tap(find.text('月度'));
      await tester.pump();

      await tester.tap(find.text('暦月'));
      await tester.pump();

      expect(fixture.viewModel.mode, BudgetPeriodMode.calendarMonth);
      expect(find.text('2026年7月（7/1〜7/31）'), findsOneWidget);
    });

    testWidgets('今日が属する期間を表示しているとき右矢印が押せず、左矢印を押すと前の期間になり右矢印で戻れること', (
      tester,
    ) async {
      await _pump(tester);
      expect(_nextButton(tester).onPressed, isNull);

      await tester.tap(find.byIcon(Icons.arrow_left));
      await tester.pump();

      expect(find.text('2026年6月（6/1〜6/30）'), findsOneWidget);
      expect(_nextButton(tester).onPressed, isNotNull);

      await tester.tap(find.byIcon(Icons.arrow_right));
      await tester.pump();

      expect(find.text('2026年7月（7/1〜7/31）'), findsOneWidget);
    });

    testWidgets('月度で左矢印を押したとき、前の月度のラベルになること', (tester) async {
      await _pump(tester);
      await tester.tap(find.text('月度'));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.arrow_left));
      await tester.pump();

      expect(find.text('2026年6月度（5/16〜6/15）'), findsOneWidget);
    });
  });

  group('一覧', () {
    testWidgets('支出カテゴリとレコードが届いたとき、カテゴリ名と「支出 / 予算」の金額が表示されること', (tester) async {
      final fixture = await _pump(tester);

      await _emit(
        tester,
        fixture,
        categories: [_food, _hobby],
        records: [_expense('food', 12000)],
      );

      expect(find.text('食費'), findsOneWidget);
      expect(find.text('¥12,000 / ¥30,000'), findsOneWidget);
      expect(find.text('趣味'), findsOneWidget);
      expect(find.text('¥0 / ¥10,000'), findsOneWidget);
      expect(find.text('削除済み'), findsNothing);
    });

    testWidgets('削除されたカテゴリを参照する支出があるとき、その合計が予算¥0の「削除済み」行として表示されること', (
      tester,
    ) async {
      final fixture = await _pump(tester);

      await _emit(
        tester,
        fixture,
        categories: [_food],
        records: [_expense('deleted-1', 2000), _expense('deleted-2', 1000)],
      );

      expect(find.text('削除済み'), findsOneWidget);
      expect(find.text('¥3,000 / ¥0'), findsOneWidget);
    });

    testWidgets(
      '支出がそれぞれ予算の半分・予算超過・予算0で支出あり・予算0で支出なしのとき、バーの塗りが半分・満タン・満タン・空になること',
      (tester) async {
        final fixture = await _pump(tester);

        await _emit(
          tester,
          fixture,
          categories: [_food, _transport, _gift, _misc],
          records: [
            _expense('food', 15000),
            _expense('transport', 8000),
            _expense('gift', 1),
          ],
        );

        final fills = tester
            .widgetList<FractionallySizedBox>(find.byType(FractionallySizedBox))
            .map((box) => box.widthFactor);
        expect(fills, [0.5, 1.0, 1.0, 0.0]);
      },
    );
  });
}

class _Fixture {
  _Fixture({
    required this.screen,
    required this.viewModel,
    required this.records,
    required this.categories,
  });

  final BudgetScreen screen;
  final BudgetViewModel viewModel;
  final FakeRecordRepository records;
  final FakeCategoryRepository categories;
}

_Fixture _buildFixture() {
  final records = FakeRecordRepository();
  final categories = FakeCategoryRepository();
  final viewModel = BudgetViewModel(
    recordRepository: records,
    categoryRepository: categories,
    now: () => _today,
  );

  return _Fixture(
    screen: BudgetScreen(viewModel: viewModel),
    viewModel: viewModel,
    records: records,
    categories: categories,
  );
}

Future<_Fixture> _pump(WidgetTester tester) async {
  final fixture = _buildFixture();
  await tester.pumpWidget(
    GoldenPageWrapper(child: Scaffold(body: fixture.screen)),
  );
  return fixture;
}

Future<void> _emit(
  WidgetTester tester,
  _Fixture fixture, {
  required List<ExpenseCategory> categories,
  required List<Record> records,
}) async {
  fixture.categories.expenseCategoriesController.add(categories);
  fixture.records.recordsController.add(records);
  await tester.pumpAndSettle();
}

IconButton _nextButton(WidgetTester tester) => tester.widget<IconButton>(
  find.widgetWithIcon(IconButton, Icons.arrow_right),
);

ExpenseCategory _category(String id, String name, int budget) =>
    ExpenseCategory(
      id: CategoryId(id),
      name: CategoryName(name),
      budget: Budget(budget),
    );

var _sequence = 0;

Record _expense(String categoryId, int amount) => Record.expense(
  id: RecordId('expense-${_sequence++}'),
  date: RecordDate(DateTime(2026, 7, 1)),
  amount: Amount(amount),
  note: RecordNote(''),
  categoryId: CategoryId(categoryId),
  propertyId: PropertyId('property'),
);
