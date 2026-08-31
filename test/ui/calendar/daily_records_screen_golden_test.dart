import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/domain/models/amount.dart';
import 'package:household_accounts/domain/models/category.dart';
import 'package:household_accounts/domain/models/category_id.dart';
import 'package:household_accounts/domain/models/category_name.dart';
import 'package:household_accounts/domain/models/property.dart';
import 'package:household_accounts/domain/models/property_id.dart';
import 'package:household_accounts/domain/models/property_name.dart';
import 'package:household_accounts/domain/models/record.dart';
import 'package:household_accounts/domain/models/record_date.dart';
import 'package:household_accounts/domain/models/record_id.dart';
import 'package:household_accounts/domain/models/record_note.dart';
import 'package:household_accounts/ui/calendar/daily_records_screen.dart';
import 'package:household_accounts/ui/calendar/daily_records_view_model.dart';

import '../../test-util/fake_category_repository.dart';
import '../../test-util/fake_property_repository.dart';
import '../../test-util/fake_record_repository.dart';
import '../../test-util/golden_helper.dart';

// 表示する日をテストから固定し、タイトルと並び順を実行日に左右されないようにする
const _year = 2026;
const _month = 8;
const _day = 31;

final _salary = IncomeCategory(
  id: CategoryId('salary'),
  name: CategoryName('給与'),
);
final _food = ExpenseCategory(id: CategoryId('food'), name: CategoryName('食費'));
final _wallet = Property(id: PropertyId('wallet'), name: PropertyName('財布'));
final _bank = Property(id: PropertyId('bank'), name: PropertyName('銀行'));

// なぜスナックバーをgoldenで確認しないか:
// ScaffoldMessengerは入れ子のScaffoldのうち最も外側にだけスナックバーを出す。
// 3幅ヘルパーはDailyRecordsScreenのScaffoldを別のScaffoldで包むため、
// スナックバーは撮影範囲の外に出る。
void main() {
  group('golden', () {
    late _Fixture fixture;

    testGoldens(
      '4本の購読が未着のとき、ローディングが表示されること',
      goldenFileName: 'daily_records_loading',
      builder: () => (fixture = _buildFixture()).screen,
    );

    testGoldens(
      '収入・支出・振替が届いたとき、日時の昇順に明細が表示されること',
      goldenFileName: 'daily_records_loaded',
      builder: () => (fixture = _buildFixture()).screen,
      expectFn: (tester) async {
        await _emit(tester, fixture, [
          _transfer(hour: 20),
          _income(hour: 9),
          _expense(hour: 12),
        ]);
      },
    );

    testGoldens(
      '参照先のカテゴリ・資産が削除されているとき、名前が削除済みと表示されること',
      goldenFileName: 'daily_records_deleted_reference',
      builder: () => (fixture = _buildFixture()).screen,
      expectFn: (tester) async {
        await _emit(tester, fixture, [
          _expense(hour: 12, categoryId: CategoryId('deleted-category')),
          _transfer(hour: 20, toPropertyId: PropertyId('deleted-property')),
        ]);
      },
    );

    testGoldens(
      'レコードが1件も無い日のとき、明細が空で表示されること',
      goldenFileName: 'daily_records_no_records',
      builder: () => (fixture = _buildFixture()).screen,
      expectFn: (tester) async {
        await _emit(tester, fixture, []);
      },
    );

    testGoldens(
      'レコードの購読が失敗したとき、エラーメッセージが表示されること',
      goldenFileName: 'daily_records_load_failed',
      builder: () => (fixture = _buildFixture()).screen,
      expectFn: (tester) async {
        fixture.recordRepository.recordsController.addError(
          Exception('watchPeriodエラー'),
        );
        await tester.pumpAndSettle();
      },
    );
  });
}

class _Fixture {
  _Fixture({
    required this.screen,
    required this.recordRepository,
    required this.categoryRepository,
    required this.propertyRepository,
  });

  final DailyRecordsScreen screen;
  final FakeRecordRepository recordRepository;
  final FakeCategoryRepository categoryRepository;
  final FakePropertyRepository propertyRepository;
}

_Fixture _buildFixture() {
  final recordRepository = FakeRecordRepository();
  final categoryRepository = FakeCategoryRepository();
  final propertyRepository = FakePropertyRepository();

  return _Fixture(
    screen: DailyRecordsScreen(
      viewModel: DailyRecordsViewModel(
        recordRepository: recordRepository,
        categoryRepository: categoryRepository,
        propertyRepository: propertyRepository,
        year: _year,
        month: _month,
        day: _day,
      ),
    ),
    recordRepository: recordRepository,
    categoryRepository: categoryRepository,
    propertyRepository: propertyRepository,
  );
}

/// 名前解決の3本とレコードを届け、読み込み完了の表示にする。
Future<void> _emit(
  WidgetTester tester,
  _Fixture fixture,
  List<Record> records,
) async {
  fixture.categoryRepository.incomeCategoriesController.add([_salary]);
  fixture.categoryRepository.expenseCategoriesController.add([_food]);
  fixture.propertyRepository.propertiesController.add([_wallet, _bank]);
  fixture.recordRepository.recordsController.add(records);
  await tester.pumpAndSettle();
}

Record _income({required int hour}) => Record.income(
  id: RecordId('income-$hour'),
  date: RecordDate(DateTime(_year, _month, _day, hour)),
  amount: Amount(250000),
  note: RecordNote('8月分'),
  categoryId: _salary.id,
  propertyId: _wallet.id,
);

Record _expense({required int hour, CategoryId? categoryId}) => Record.expense(
  id: RecordId('expense-$hour'),
  date: RecordDate(DateTime(_year, _month, _day, hour)),
  amount: Amount(1280),
  note: RecordNote('ランチ'),
  categoryId: categoryId ?? _food.id,
  propertyId: _wallet.id,
);

Record _transfer({required int hour, PropertyId? toPropertyId}) =>
    Record.transfer(
      id: RecordId('transfer-$hour'),
      date: RecordDate(DateTime(_year, _month, _day, hour)),
      amount: Amount(50000),
      note: RecordNote(''),
      fromPropertyId: _wallet.id,
      toPropertyId: toPropertyId ?? _bank.id,
    );
