import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/domain/models/amount.dart';
import 'package:household_accounts/domain/models/category_id.dart';
import 'package:household_accounts/domain/models/period.dart';
import 'package:household_accounts/domain/models/property_id.dart';
import 'package:household_accounts/domain/models/record.dart';
import 'package:household_accounts/domain/models/record_date.dart';
import 'package:household_accounts/domain/models/record_id.dart';
import 'package:household_accounts/domain/models/record_note.dart';
import 'package:household_accounts/ui/calendar/calendar_view_model.dart';

import '../../test-util/fake_record_repository.dart';

// なぜtestWidgetsではなくtestを使うか:
// CalendarViewModelは純粋なDartのChangeNotifierであり、Widgetツリーを
// 必要としない。また、testWidgets内で`await streamController.close()`や
// `await subscription.cancel()`をawaitするとハングする既知の問題があるため、
// それを踏まないためにもplain testを使い、ストリームイベントの反映は
// `pumpEventQueue()`で待つ。
void main() {
  group('初期表示', () {
    test('生成した直後のとき、現在月のレコードの購読が1回始まること', () {
      final target = _buildViewModel();

      expect(target.viewModel.year, 2026);
      expect(target.viewModel.month, 8);
      expect(target.recordRepository.watchPeriodCallCount, 1);
      expect(
        target.recordRepository.lastWatchedPeriod,
        Period.calendarMonth(2026, 8),
      );
    });

    test('レコードが未発行のとき、集計がnull(読み込み中)であること', () {
      final target = _buildViewModel();

      expect(target.viewModel.dailySummaries, isNull);
    });
  });

  group('日別の集計', () {
    test('複数の日にレコードが発行されたとき、日ごとに収入・支出・振替が合計されること', () async {
      final target = _buildViewModel();

      target.recordRepository.recordsController.add([
        _income(day: 3, amount: 1000),
        _income(day: 3, amount: 200),
        _expense(day: 3, amount: 500),
        _transfer(day: 20, amount: 3000),
      ]);
      await pumpEventQueue();

      expect(target.viewModel.dailySummaries?[3]?.income, 1200);
      expect(target.viewModel.dailySummaries?[3]?.expense, 500);
      expect(target.viewModel.dailySummaries?[3]?.transfer, 0);
      expect(target.viewModel.dailySummaries?[20]?.transfer, 3000);
    });

    test('レコードのない日のとき、集計にその日のキーが無いこと', () async {
      final target = _buildViewModel();

      target.recordRepository.recordsController.add([
        _income(day: 3, amount: 1000),
      ]);
      await pumpEventQueue();

      expect(target.viewModel.dailySummaries?.containsKey(4), isFalse);
    });

    test('空のレコードが発行されたとき、集計が空のMapになること', () async {
      final target = _buildViewModel();

      target.recordRepository.recordsController.add([]);
      await pumpEventQueue();

      expect(target.viewModel.dailySummaries, isEmpty);
    });

    test('2回目のレコードが発行されたとき、集計が新しい内容へ更新されること', () async {
      final target = _buildViewModel();

      target.recordRepository.recordsController.add([
        _income(day: 3, amount: 1000),
      ]);
      await pumpEventQueue();
      expect(target.viewModel.dailySummaries?[3]?.income, 1000);

      target.recordRepository.recordsController.add([
        _income(day: 3, amount: 1000),
        _income(day: 3, amount: 400),
      ]);
      await pumpEventQueue();

      expect(target.viewModel.dailySummaries?[3]?.income, 1400);
    });
  });

  group('月の切り替え', () {
    test('前の月へ切り替えたとき、前の月のレコードを購読し直し読み込み中へ戻ること', () async {
      final target = _buildViewModel();
      target.recordRepository.recordsController.add([
        _income(day: 3, amount: 1000),
      ]);
      await pumpEventQueue();

      target.viewModel.showPreviousMonth();

      expect(target.viewModel.year, 2026);
      expect(target.viewModel.month, 7);
      expect(target.recordRepository.watchPeriodCallCount, 2);
      expect(
        target.recordRepository.lastWatchedPeriod,
        Period.calendarMonth(2026, 7),
      );
      expect(target.viewModel.dailySummaries, isNull);
    });

    test('前の月を表示中に次の月へ切り替えたとき、現在月のレコードを購読し直すこと', () {
      final target = _buildViewModel();
      target.viewModel.showPreviousMonth();

      target.viewModel.showNextMonth();

      expect(target.viewModel.month, 8);
      expect(target.recordRepository.watchPeriodCallCount, 3);
      expect(
        target.recordRepository.lastWatchedPeriod,
        Period.calendarMonth(2026, 8),
      );
    });

    test('1月を表示中に前の月へ切り替えたとき、前年の12月を購読すること', () {
      final target = _buildViewModel(currentYear: 2026, currentMonth: 1);

      target.viewModel.showPreviousMonth();

      expect(target.viewModel.year, 2025);
      expect(target.viewModel.month, 12);
      expect(
        target.recordRepository.lastWatchedPeriod,
        Period.calendarMonth(2025, 12),
      );
    });

    test('前の月へ切り替えたあとレコードが発行されたとき、新しい月の集計が反映されること', () async {
      final target = _buildViewModel();

      target.viewModel.showPreviousMonth();
      target.recordRepository.recordsController.add([
        _income(day: 10, amount: 700),
      ]);
      await pumpEventQueue();

      expect(target.viewModel.dailySummaries?[10]?.income, 700);
    });

    test('現在月を表示中のとき、次の月へ進めないこと', () {
      final target = _buildViewModel();

      expect(target.viewModel.canShowNextMonth, isFalse);

      target.viewModel.showNextMonth();

      expect(target.viewModel.month, 8);
      expect(target.recordRepository.watchPeriodCallCount, 1);
    });

    test('過去の月を表示中のとき、次の月へ進めること', () {
      final target = _buildViewModel();

      target.viewModel.showPreviousMonth();

      expect(target.viewModel.canShowNextMonth, isTrue);
    });
  });

  group('購読のエラー', () {
    test('レコードの購読がExceptionを流したとき、recordsErrorにその例外が保持されること', () async {
      final target = _buildViewModel();
      final exception = Exception('watchPeriodエラー');

      target.recordRepository.recordsController.addError(exception);
      await pumpEventQueue();

      expect(target.viewModel.recordsError, exception);
    });

    test('エラーのあとに正常なレコードが発行されたとき、recordsErrorが解消されること', () async {
      final target = _buildViewModel();

      target.recordRepository.recordsController.addError(
        Exception('watchPeriodエラー'),
      );
      await pumpEventQueue();
      expect(target.viewModel.recordsError, isNotNull);

      target.recordRepository.recordsController.add([
        _income(day: 3, amount: 1000),
      ]);
      await pumpEventQueue();

      expect(target.viewModel.recordsError, isNull);
      expect(target.viewModel.dailySummaries?[3]?.income, 1000);
    });

    test('エラーのあとに別の月へ切り替えたとき、recordsErrorが引き継がれないこと', () async {
      final target = _buildViewModel();

      target.recordRepository.recordsController.addError(
        Exception('watchPeriodエラー'),
      );
      await pumpEventQueue();

      target.viewModel.showPreviousMonth();

      expect(target.viewModel.recordsError, isNull);
    });

    test('レコードの購読がError(実装バグ)を流したとき、状態化されず再送出されること', () async {
      // 再送出はStreamSubscriptionのonErrorコールバック内で起きるため、
      // 購読を開始したZoneの未処理エラーとして観測する(そのままだとテスト全体の
      // 失敗になり、どのtest()の失敗として報告されるかも不安定になる)。
      Object? uncaughtError;
      late _Fixture target;
      runZonedGuarded(
        () => target = _buildViewModel(),
        (error, stackTrace) => uncaughtError = error,
      );

      target.recordRepository.recordsController.addError(ArgumentError('実装バグ'));
      await pumpEventQueue();

      expect(uncaughtError, isA<ArgumentError>());
      expect(target.viewModel.recordsError, isNull);
    });
  });

  group('破棄', () {
    test('disposeしたとき、レコードの購読が解除されること', () async {
      final target = _buildViewModel();

      target.viewModel.dispose();
      await pumpEventQueue();

      expect(target.recordRepository.recordsController.hasListener, isFalse);
    });
  });
}

class _Fixture {
  _Fixture({required this.viewModel, required this.recordRepository});

  final CalendarViewModel viewModel;
  final FakeRecordRepository recordRepository;
}

_Fixture _buildViewModel({int currentYear = 2026, int currentMonth = 8}) {
  final recordRepository = FakeRecordRepository();

  return _Fixture(
    viewModel: CalendarViewModel(
      recordRepository: recordRepository,
      currentYear: currentYear,
      currentMonth: currentMonth,
    ),
    recordRepository: recordRepository,
  );
}

Record _income({required int day, required int amount}) => Record.income(
  id: RecordId('income-id-$day-$amount'),
  date: RecordDate(DateTime(2026, 8, day)),
  amount: Amount(amount),
  note: RecordNote(''),
  categoryId: CategoryId('category-id'),
  propertyId: PropertyId('property-id'),
);

Record _expense({required int day, required int amount}) => Record.expense(
  id: RecordId('expense-id-$day-$amount'),
  date: RecordDate(DateTime(2026, 8, day)),
  amount: Amount(amount),
  note: RecordNote(''),
  categoryId: CategoryId('category-id'),
  propertyId: PropertyId('property-id'),
);

Record _transfer({required int day, required int amount}) => Record.transfer(
  id: RecordId('transfer-id-$day-$amount'),
  date: RecordDate(DateTime(2026, 8, day)),
  amount: Amount(amount),
  note: RecordNote(''),
  fromPropertyId: PropertyId('from-property-id'),
  toPropertyId: PropertyId('to-property-id'),
);
