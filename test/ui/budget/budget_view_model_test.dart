import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/domain/models/amount.dart';
import 'package:household_accounts/domain/models/budget.dart';
import 'package:household_accounts/domain/models/budget_summary.dart';
import 'package:household_accounts/domain/models/category.dart';
import 'package:household_accounts/domain/models/category_id.dart';
import 'package:household_accounts/domain/models/category_name.dart';
import 'package:household_accounts/domain/models/fiscal_month.dart';
import 'package:household_accounts/domain/models/period.dart';
import 'package:household_accounts/domain/models/property_id.dart';
import 'package:household_accounts/domain/models/record.dart';
import 'package:household_accounts/domain/models/record_date.dart';
import 'package:household_accounts/domain/models/record_id.dart';
import 'package:household_accounts/domain/models/record_note.dart';
import 'package:household_accounts/ui/budget/budget_view_model.dart';

import '../../test-util/fake_category_repository.dart';
import '../../test-util/fake_record_repository.dart';

final _food = ExpenseCategory(
  id: CategoryId('food'),
  name: CategoryName('食費'),
  budget: Budget(30000),
);
final _hobby = ExpenseCategory(
  id: CategoryId('hobby'),
  name: CategoryName('趣味'),
  budget: Budget(10000),
);

// なぜtestWidgetsではなくtestを使うか:
// BudgetViewModelは純粋なDartのChangeNotifierであり、Widgetツリーを
// 必要としない。また、testWidgets内で`await streamController.close()`や
// `await subscription.cancel()`をawaitするとハングする既知の問題があるため、
// それを踏まないためにもplain testを使い、ストリームイベントの反映は
// `pumpEventQueue()`で待つ。
void main() {
  group('初期表示', () {
    test('生成した直後のとき、今日の暦月のレコードと支出カテゴリの購読が1回ずつ始まり、読み込み中であること', () {
      final target = _buildFixture();

      expect(target.viewModel.mode, BudgetPeriodMode.calendarMonth);
      expect(target.viewModel.year, 2026);
      expect(target.viewModel.month, 7);
      expect(target.records.watchedPeriods, [Period.calendarMonth(2026, 7)]);
      expect(target.categories.watchExpenseCategoriesCallCount, 1);
      expect(target.viewModel.summary, isNull);
      expect(target.viewModel.loadError, isNull);
    });

    test('支出カテゴリだけが届いたとき、読み込み中のままであること', () async {
      final target = _buildFixture();

      target.categories.expenseCategoriesController.add([_food]);
      await pumpEventQueue();

      expect(target.viewModel.summary, isNull);
    });

    test('レコードだけが届いたとき、読み込み中のままであること', () async {
      final target = _buildFixture();

      target.records.recordsController.add([_expense('food', 1000)]);
      await pumpEventQueue();

      expect(target.viewModel.summary, isNull);
    });

    test('支出カテゴリとレコードの両方が届いたとき、カテゴリごとの支出が集計されること', () async {
      final target = _buildFixture();
      final records = [_expense('food', 1200), _expense('deleted', 300)];

      target.categories.expenseCategoriesController.add([_food, _hobby]);
      target.records.recordsController.add(records);
      await pumpEventQueue();

      expect(
        target.viewModel.summary,
        BudgetSummary.from([_food, _hobby], records),
      );
    });

    test('2回目のレコードが届いたとき、集計が新しい内容へ更新されること', () async {
      final target = _buildFixture();
      target.categories.expenseCategoriesController.add([_food]);
      target.records.recordsController.add([_expense('food', 1000)]);
      await pumpEventQueue();

      target.records.recordsController.add([
        _expense('food', 1000),
        _expense('food', 500),
      ]);
      await pumpEventQueue();

      expect(target.viewModel.summary?.categories.single.spent, 1500);
    });
  });

  group('モードの切り替え', () {
    test('今日が7/5のとき月度へ切り替えると、7月度のレコードを購読し直すこと', () {
      final target = _buildFixture(today: DateTime(2026, 7, 5));

      target.viewModel.selectMode(BudgetPeriodMode.fiscalMonth);

      expect(target.viewModel.mode, BudgetPeriodMode.fiscalMonth);
      expect(target.viewModel.year, 2026);
      expect(target.viewModel.month, 7);
      expect(target.records.watchedPeriods.last, FiscalMonth(2026, 7).period);
    });

    test('今日が7/20のとき月度へ切り替えると、8月度のレコードを購読し直すこと', () {
      final target = _buildFixture(today: DateTime(2026, 7, 20));

      target.viewModel.selectMode(BudgetPeriodMode.fiscalMonth);

      expect(target.viewModel.month, 8);
      expect(target.records.watchedPeriods.last, FiscalMonth(2026, 8).period);
    });

    test('過去の期間を表示中にモードを切り替えたとき、切り替えたモードで今日が属する期間に戻ること', () {
      final target = _buildFixture(today: DateTime(2026, 7, 5));
      target.viewModel.showPrevious();

      target.viewModel.selectMode(BudgetPeriodMode.fiscalMonth);

      expect(target.records.watchedPeriods.last, FiscalMonth(2026, 7).period);

      target.viewModel.showPrevious();
      target.viewModel.selectMode(BudgetPeriodMode.calendarMonth);

      expect(target.viewModel.year, 2026);
      expect(target.viewModel.month, 7);
      expect(target.records.watchedPeriods.last, Period.calendarMonth(2026, 7));
    });

    test('選択中のモードをもう一度選んだとき、購読し直さず表示中の期間も変わらないこと', () {
      final target = _buildFixture();
      target.viewModel.showPrevious();

      target.viewModel.selectMode(BudgetPeriodMode.calendarMonth);

      expect(target.viewModel.month, 6);
      expect(target.records.watchPeriodCallCount, 2);
    });
  });

  group('期間送り', () {
    test('前の期間へ移ったとき、レコードだけが読み込み中へ戻り、支出カテゴリは届き直さなくても集計に使われること', () async {
      final target = _buildFixture();
      target.categories.expenseCategoriesController.add([_food]);
      target.records.recordsController.add([_expense('food', 1000)]);
      await pumpEventQueue();

      target.viewModel.showPrevious();

      expect(target.viewModel.month, 6);
      expect(target.records.watchedPeriods.last, Period.calendarMonth(2026, 6));
      expect(target.viewModel.summary, isNull);
      expect(target.categories.watchExpenseCategoriesCallCount, 1);

      target.records.recordsController.add([_expense('food', 700)]);
      await pumpEventQueue();

      expect(target.viewModel.summary?.categories, [
        (category: _food, spent: 700),
      ]);
    });

    test('暦月で今日の月を表示中のとき次へ進めず、前の月へ戻ると次へ進んで今日の月へ戻れること', () {
      final target = _buildFixture(today: DateTime(2026, 7, 5));

      expect(target.viewModel.canShowNext, isFalse);
      target.viewModel.showNext();
      expect(target.viewModel.month, 7);
      expect(target.records.watchPeriodCallCount, 1);

      target.viewModel.showPrevious();
      expect(target.viewModel.canShowNext, isTrue);

      target.viewModel.showNext();
      expect(target.viewModel.month, 7);
      expect(target.records.watchedPeriods.last, Period.calendarMonth(2026, 7));
    });

    test('月度で今日が属する月度を表示中のとき次へ進めず、前の月度へ戻ると次へ進んで今日の月度へ戻れること', () {
      final target = _buildFixture(today: DateTime(2026, 7, 20));
      target.viewModel.selectMode(BudgetPeriodMode.fiscalMonth);
      final callCount = target.records.watchPeriodCallCount;

      expect(target.viewModel.canShowNext, isFalse);
      target.viewModel.showNext();
      expect(target.viewModel.month, 8);
      expect(target.records.watchPeriodCallCount, callCount);

      target.viewModel.showPrevious();
      expect(target.viewModel.month, 7);
      expect(target.records.watchedPeriods.last, FiscalMonth(2026, 7).period);
      expect(target.viewModel.canShowNext, isTrue);

      target.viewModel.showNext();
      expect(target.records.watchedPeriods.last, FiscalMonth(2026, 8).period);
    });

    test('暦月で1月を表示中に前へ移ったとき、前年の12月を購読すること', () {
      final target = _buildFixture(today: DateTime(2027, 1, 5));

      target.viewModel.showPrevious();

      expect(target.viewModel.year, 2026);
      expect(target.viewModel.month, 12);
      expect(
        target.records.watchedPeriods.last,
        Period.calendarMonth(2026, 12),
      );
    });

    test('今日が12/20のとき月度へ切り替えると翌年1月度になり、前へ移ると12月度を購読すること', () {
      final target = _buildFixture(today: DateTime(2026, 12, 20));
      target.viewModel.selectMode(BudgetPeriodMode.fiscalMonth);

      expect(target.viewModel.year, 2027);
      expect(target.viewModel.month, 1);
      expect(target.viewModel.canShowNext, isFalse);

      target.viewModel.showPrevious();

      expect(target.viewModel.year, 2026);
      expect(target.viewModel.month, 12);
      expect(target.records.watchedPeriods.last, FiscalMonth(2026, 12).period);
    });

    test('月度を表示したまま今日が16日になったとき、次の月度へ進めるようになること', () {
      // タブがIndexedStackに保持されたままのVMを想定し、生成後に現在日時が
      // 進んだ状況を可変の時計で再現する
      var today = DateTime(2026, 7, 15, 23, 59);
      final target = _buildFixture(now: () => today);
      target.viewModel.selectMode(BudgetPeriodMode.fiscalMonth);
      expect(target.viewModel.canShowNext, isFalse);

      today = DateTime(2026, 7, 16);

      expect(target.viewModel.canShowNext, isTrue);
    });
  });

  group('今日の確認', () {
    test('同じ月のうちに日付が変わってからrefreshTodayを呼んだとき、リスナーへ通知されること', () {
      var today = DateTime(2026, 7, 15, 23, 59);
      final target = _buildFixture(now: () => today);
      var notifiedCount = 0;
      target.viewModel.addListener(() => notifiedCount++);

      today = DateTime(2026, 7, 16);
      target.viewModel.refreshToday();

      expect(notifiedCount, 1);
    });

    test('日付が変わっていないときにrefreshTodayを呼んでも、通知されないこと', () {
      var today = DateTime(2026, 7, 5, 9);
      final target = _buildFixture(now: () => today);
      var notifiedCount = 0;
      target.viewModel.addListener(() => notifiedCount++);

      today = DateTime(2026, 7, 5, 21);
      target.viewModel.refreshToday();

      expect(notifiedCount, 0);
    });
  });

  group('購読のエラー', () {
    test(
      '支出カテゴリの購読がExceptionを流したとき、レコードが届いていてもloadErrorにその例外が保持されること',
      () async {
        final target = _buildFixture();
        final exception = Exception('watchExpenseCategoriesエラー');

        target.categories.expenseCategoriesController.addError(exception);
        target.records.recordsController.add([]);
        await pumpEventQueue();

        expect(target.viewModel.loadError, exception);
      },
    );

    test('支出カテゴリのエラーのあとに正常な一覧が届いたとき、loadErrorが解消され集計されること', () async {
      final target = _buildFixture();
      target.categories.expenseCategoriesController.addError(Exception('エラー'));
      target.records.recordsController.add([_expense('food', 1000)]);
      await pumpEventQueue();

      target.categories.expenseCategoriesController.add([_food]);
      await pumpEventQueue();

      expect(target.viewModel.loadError, isNull);
      expect(target.viewModel.summary?.categories.single.spent, 1000);
    });

    test(
      'レコードの購読がExceptionを流したとき、loadErrorにその例外が保持され、正常なレコードが届くと解消されること',
      () async {
        final target = _buildFixture();
        final exception = Exception('watchPeriodエラー');
        target.categories.expenseCategoriesController.add([_food]);

        target.records.recordsController.addError(exception);
        await pumpEventQueue();
        expect(target.viewModel.loadError, exception);

        target.records.recordsController.add([_expense('food', 1000)]);
        await pumpEventQueue();

        expect(target.viewModel.loadError, isNull);
        expect(target.viewModel.summary?.categories.single.spent, 1000);
      },
    );

    test('レコードのエラーのあとに期間を変えたとき、エラーが引き継がれないこと', () async {
      final target = _buildFixture();
      target.records.recordsController.addError(Exception('watchPeriodエラー'));
      await pumpEventQueue();

      target.viewModel.showPrevious();

      expect(target.viewModel.loadError, isNull);
    });

    test('支出カテゴリのエラーのあとに期間を変えたとき、エラーが保たれること', () async {
      // カテゴリの購読は期間を変えても張り替えないため、回復していない
      final target = _buildFixture();
      final exception = Exception('watchExpenseCategoriesエラー');
      target.categories.expenseCategoriesController.addError(exception);
      await pumpEventQueue();

      target.viewModel.showPrevious();

      expect(target.viewModel.loadError, exception);
    });

    test('購読がError(実装バグ)を流したとき、状態化されず再送出されること', () async {
      // 再送出はStreamSubscriptionのonErrorコールバック内で起きるため、
      // 購読を開始したZoneの未処理エラーとして観測する(そのままだとテスト全体の
      // 失敗になり、どのtest()の失敗として報告されるかも不安定になる)。
      final uncaughtErrors = <Object>[];
      late _Fixture target;
      runZonedGuarded(
        () => target = _buildFixture(),
        (error, stackTrace) => uncaughtErrors.add(error),
      );

      target.categories.expenseCategoriesController.addError(
        ArgumentError('実装バグ'),
      );
      target.records.recordsController.addError(StateError('実装バグ'));
      await pumpEventQueue();

      expect(uncaughtErrors, [isA<ArgumentError>(), isA<StateError>()]);
      expect(target.viewModel.loadError, isNull);
    });
  });

  group('破棄', () {
    test('disposeしたとき、支出カテゴリとレコードの購読が解除されること', () async {
      final target = _buildFixture();

      target.viewModel.dispose();
      await pumpEventQueue();

      expect(
        target.categories.expenseCategoriesController.hasListener,
        isFalse,
      );
      expect(target.records.recordsController.hasListener, isFalse);
    });
  });
}

class _Fixture {
  _Fixture({
    required this.viewModel,
    required this.records,
    required this.categories,
  });

  final BudgetViewModel viewModel;
  final FakeRecordRepository records;
  final FakeCategoryRepository categories;
}

_Fixture _buildFixture({DateTime? today, DateTime Function()? now}) {
  final records = FakeRecordRepository();
  final categories = FakeCategoryRepository();
  final fixedToday = today ?? DateTime(2026, 7, 5);

  return _Fixture(
    viewModel: BudgetViewModel(
      recordRepository: records,
      categoryRepository: categories,
      now: now ?? () => fixedToday,
    ),
    records: records,
    categories: categories,
  );
}

var _sequence = 0;

Record _expense(String categoryId, int amount) => Record.expense(
  id: RecordId('expense-${_sequence++}'),
  date: RecordDate(DateTime(2026, 7, 1)),
  amount: Amount(amount),
  note: RecordNote(''),
  categoryId: CategoryId(categoryId),
  propertyId: PropertyId('property'),
);
