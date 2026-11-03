import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/domain/models/amount.dart';
import 'package:household_accounts/domain/models/category_id.dart';
import 'package:household_accounts/domain/models/property_id.dart';
import 'package:household_accounts/domain/models/record.dart';
import 'package:household_accounts/domain/models/record_date.dart';
import 'package:household_accounts/domain/models/record_id.dart';
import 'package:household_accounts/domain/models/record_note.dart';
import 'package:household_accounts/ui/calendar/calendar_screen.dart';
import 'package:household_accounts/ui/calendar/calendar_view_model.dart';

import '../../test-util/fake_record_repository.dart';
import '../../test-util/golden_helper.dart';

// 「現在月」をテストから固定し、表示する月と矢印の押下可否を実行日に
// 左右されないようにする
const _currentYear = 2026;
const _currentMonth = 8;

void main() {
  group('golden', () {
    late _Fixture fixture;

    testGoldens(
      'レコードが未着のとき、月ヘッダとローディングが表示されること',
      goldenFileName: 'calendar_loading',
      builder: () => (fixture = _buildFixture()).screen,
    );

    testGoldens(
      'レコードが届いたとき、日ごとの合計が表示されること',
      goldenFileName: 'calendar_loaded',
      builder: () => (fixture = _buildFixture()).screen,
      expectFn: (tester) async {
        await _emitRecords(tester, fixture, [
          _income(day: 3, amount: 250000),
          _expense(day: 3, amount: 1280),
          _expense(day: 12, amount: 980),
          _transfer(day: 20, amount: 50000),
        ]);
      },
    );

    testGoldens(
      'レコードが1件も無いとき、すべての日が¥0で表示されること',
      goldenFileName: 'calendar_no_records',
      builder: () => (fixture = _buildFixture()).screen,
      expectFn: (tester) async {
        await _emitRecords(tester, fixture, []);
      },
    );

    testGoldens(
      'レコードの購読が失敗したとき、エラーメッセージが表示されること',
      goldenFileName: 'calendar_load_failed',
      builder: () => (fixture = _buildFixture()).screen,
      expectFn: (tester) async {
        fixture.recordRepository.recordsController.addError(
          Exception('watchPeriodエラー'),
        );
        await tester.pumpAndSettle();
      },
    );

    testGoldens(
      '過去の月を表示しているとき、左右どちらの矢印も押下できること',
      goldenFileName: 'calendar_previous_month',
      builder: () => (fixture = _buildFixture()).screen,
      expectFn: (tester) async {
        fixture.viewModel.showPreviousMonth();
        await _emitRecords(tester, fixture, [_income(day: 5, amount: 3000)]);
      },
    );
  });
}

class _Fixture {
  _Fixture({
    required this.screen,
    required this.viewModel,
    required this.recordRepository,
  });

  final CalendarScreen screen;
  final CalendarViewModel viewModel;
  final FakeRecordRepository recordRepository;
}

_Fixture _buildFixture() {
  final recordRepository = FakeRecordRepository();
  final viewModel = CalendarViewModel(
    recordRepository: recordRepository,
    now: () => DateTime(_currentYear, _currentMonth, 15),
  );

  return _Fixture(
    screen: CalendarScreen(viewModel: viewModel),
    viewModel: viewModel,
    recordRepository: recordRepository,
  );
}

Future<void> _emitRecords(
  WidgetTester tester,
  _Fixture fixture,
  List<Record> records,
) async {
  fixture.recordRepository.recordsController.add(records);
  await tester.pumpAndSettle();
}

// 日別集計は日付の月を見ない(期間の絞り込みはRepositoryの責務)ため、
// どのセルへ出るかは日だけで決まる
RecordDate _dateOf(int day) =>
    RecordDate(DateTime(_currentYear, _currentMonth, day));

Record _income({required int day, required int amount}) => Record.income(
  id: RecordId('income-id-$day'),
  date: _dateOf(day),
  amount: Amount(amount),
  note: RecordNote(''),
  categoryId: CategoryId('category-id'),
  propertyId: PropertyId('property-id'),
);

Record _expense({required int day, required int amount}) => Record.expense(
  id: RecordId('expense-id-$day'),
  date: _dateOf(day),
  amount: Amount(amount),
  note: RecordNote(''),
  categoryId: CategoryId('category-id'),
  propertyId: PropertyId('property-id'),
);

Record _transfer({required int day, required int amount}) => Record.transfer(
  id: RecordId('transfer-id-$day'),
  date: _dateOf(day),
  amount: Amount(amount),
  note: RecordNote(''),
  fromPropertyId: PropertyId('from-property-id'),
  toPropertyId: PropertyId('to-property-id'),
);
