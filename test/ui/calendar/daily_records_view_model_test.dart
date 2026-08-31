import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/domain/models/amount.dart';
import 'package:household_accounts/domain/models/category.dart';
import 'package:household_accounts/domain/models/category_id.dart';
import 'package:household_accounts/domain/models/category_name.dart';
import 'package:household_accounts/domain/models/period.dart';
import 'package:household_accounts/domain/models/property.dart';
import 'package:household_accounts/domain/models/property_id.dart';
import 'package:household_accounts/domain/models/property_name.dart';
import 'package:household_accounts/domain/models/record.dart';
import 'package:household_accounts/domain/models/record_date.dart';
import 'package:household_accounts/domain/models/record_id.dart';
import 'package:household_accounts/domain/models/record_note.dart';
import 'package:household_accounts/ui/calendar/daily_records_view_model.dart';
import 'package:household_accounts/utils/result.dart';

import '../../test-util/fake_category_repository.dart';
import '../../test-util/fake_property_repository.dart';
import '../../test-util/fake_record_repository.dart';

// 表示する日をテストから固定し、購読する期間と並び順を実行日に左右されない
// ようにする
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

// なぜtestWidgetsではなくtestを使うか:
// DailyRecordsViewModelは純粋なDartのChangeNotifierであり、Widgetツリーを
// 必要としない。また、testWidgets内で`await streamController.close()`や
// `await subscription.cancel()`をawaitするとハングする既知の問題があるため、
// それを踏まないためにもplain testを使い、ストリームイベントの反映は
// `pumpEventQueue()`で待つ。
//
// なぜCommandの実行状態を網羅的に確かめないか:
// running/completed/errorの振る舞いはCommand自体の責務であり
// test/utils/command_test.dartで固定済みなので、ここでは画面の挙動を
// 説明するのに必要な範囲だけを確かめる。
void main() {
  group('初期表示', () {
    test('生成した直後のとき、指定した日の1日分のレコードの購読が1回始まること', () {
      final target = _buildFixture();

      expect(target.recordRepository.watchPeriodCallCount, 1);
      expect(
        target.recordRepository.lastWatchedPeriod,
        Period.day(_year, _month, _day),
      );
    });

    test('生成した直後のとき、カテゴリ2本と資産の購読がそれぞれ1回始まること', () {
      final target = _buildFixture();

      expect(target.categoryRepository.watchIncomeCategoriesCallCount, 1);
      expect(target.categoryRepository.watchExpenseCategoriesCallCount, 1);
      expect(target.propertyRepository.watchAllCallCount, 1);
    });

    test('4本のうちレコードだけが届いたとき、isLoadingがtrueのままであること', () async {
      final target = _buildFixture();

      target.recordRepository.recordsController.add([_income(hour: 9)]);
      await pumpEventQueue();

      expect(target.viewModel.isLoading, isTrue);
    });

    test('4本のうち名前解決の3本だけが届いたとき、isLoadingがtrueのままであること', () async {
      final target = _buildFixture();

      target.categoryRepository.incomeCategoriesController.add([_salary]);
      target.categoryRepository.expenseCategoriesController.add([_food]);
      target.propertyRepository.propertiesController.add([_wallet, _bank]);
      await pumpEventQueue();

      expect(target.viewModel.isLoading, isTrue);
    });

    test('4本すべてが届いたとき、isLoadingがfalseになること', () async {
      final target = await _buildLoadedFixture();

      expect(target.viewModel.isLoading, isFalse);
    });

    test('レコードが1件も無い日のとき、一覧が空になること', () async {
      final target = await _buildLoadedFixture();

      expect(target.viewModel.records, isEmpty);
    });
  });

  group('並び順', () {
    test('日時の異なるレコードが届いたとき、日時の昇順に並ぶこと', () async {
      final target = await _buildLoadedFixture();

      target.recordRepository.recordsController.add([
        _transfer(hour: 20),
        _income(hour: 9),
        _expense(hour: 12),
      ]);
      await pumpEventQueue();

      expect(target.viewModel.records.map((record) => record.id.value), [
        'income-9',
        'expense-12',
        'transfer-20',
      ]);
    });

    test('日時が同じレコードが届いたとき、レコードIDの昇順に並ぶこと', () async {
      final target = await _buildLoadedFixture();

      target.recordRepository.recordsController.add([
        _expense(hour: 9, id: 'expense-c'),
        _income(hour: 9, id: 'income-a'),
        _expense(hour: 9, id: 'expense-b'),
      ]);
      await pumpEventQueue();

      expect(target.viewModel.records.map((record) => record.id.value), [
        'expense-b',
        'expense-c',
        'income-a',
      ]);
    });

    test('2回目のレコードが発行されたとき、一覧が新しい内容へ更新されること', () async {
      final target = await _buildLoadedFixture();

      target.recordRepository.recordsController.add([_income(hour: 9)]);
      await pumpEventQueue();
      expect(target.viewModel.records, hasLength(1));

      target.recordRepository.recordsController.add([
        _income(hour: 9),
        _expense(hour: 12),
      ]);
      await pumpEventQueue();

      expect(target.viewModel.records, hasLength(2));
    });
  });

  group('名前の逆引き', () {
    test('カテゴリと資産が届いたとき、IDから名前を引けること', () async {
      final target = await _buildLoadedFixture();

      expect(target.viewModel.incomeCategoryNameOf(_salary.id), '給与');
      expect(target.viewModel.expenseCategoryNameOf(_food.id), '食費');
      expect(target.viewModel.propertyNameOf(_wallet.id), '財布');
    });

    test('参照先のカテゴリが存在しないとき、名前がnullになること', () async {
      final target = await _buildLoadedFixture();

      expect(
        target.viewModel.incomeCategoryNameOf(CategoryId('deleted')),
        isNull,
      );
      expect(
        target.viewModel.expenseCategoryNameOf(CategoryId('deleted')),
        isNull,
      );
    });

    test('参照先の資産が存在しないとき、名前がnullになること', () async {
      final target = await _buildLoadedFixture();

      expect(target.viewModel.propertyNameOf(PropertyId('deleted')), isNull);
    });

    test('収入カテゴリと同じIDで支出カテゴリを引いたとき、名前が引けないこと', () async {
      // 収入と支出は別コレクションでIDの一意性も別々のため、逆引きを混ぜない
      final target = await _buildLoadedFixture();

      expect(target.viewModel.expenseCategoryNameOf(_salary.id), isNull);
    });

    test('カテゴリが削除されて再発行されたとき、名前が引けなくなること', () async {
      final target = await _buildLoadedFixture();

      target.categoryRepository.incomeCategoriesController.add([]);
      await pumpEventQueue();

      expect(target.viewModel.incomeCategoryNameOf(_salary.id), isNull);
    });
  });

  group('レコードの削除', () {
    test('削除を実行したとき、対象のレコードがRepositoryへ1回だけ渡ること', () async {
      final target = await _buildLoadedFixture();
      final record = _income(hour: 9);

      await target.viewModel.deleteRecord.execute(record);

      expect(target.recordRepository.deleteCallCount, 1);
      expect(target.recordRepository.lastDeletedRecord, record);
    });

    test('削除が失敗したとき、コマンドがエラーになること', () async {
      final target = await _buildLoadedFixture();
      target.recordRepository.deleteResult = Result.error(
        Exception('deleteエラー'),
      );

      await target.viewModel.deleteRecord.execute(_income(hour: 9));

      expect(target.viewModel.deleteRecord.error, isTrue);
    });

    test('削除が成功したとき、コマンドが完了になること', () async {
      final target = await _buildLoadedFixture();

      await target.viewModel.deleteRecord.execute(_income(hour: 9));

      expect(target.viewModel.deleteRecord.completed, isTrue);
    });
  });

  group('購読のエラー', () {
    test('レコードの購読がExceptionを流したとき、loadErrorにその例外が保持されること', () async {
      final target = _buildFixture();
      final exception = Exception('watchPeriodエラー');

      target.recordRepository.recordsController.addError(exception);
      await pumpEventQueue();

      expect(target.viewModel.loadError, exception);
    });

    test('資産の購読がExceptionを流したとき、loadErrorにその例外が保持されること', () async {
      final target = _buildFixture();
      final exception = Exception('watchAllエラー');

      target.propertyRepository.propertiesController.addError(exception);
      await pumpEventQueue();

      expect(target.viewModel.loadError, exception);
    });

    test('エラーのあとに正常なレコードが発行されたとき、loadErrorが解消されること', () async {
      final target = _buildFixture();

      target.recordRepository.recordsController.addError(
        Exception('watchPeriodエラー'),
      );
      await pumpEventQueue();
      expect(target.viewModel.loadError, isNotNull);

      target.recordRepository.recordsController.add([_income(hour: 9)]);
      await pumpEventQueue();

      expect(target.viewModel.loadError, isNull);
    });

    test('資産の購読が失敗しているとき、レコードの正常な発行ではloadErrorが解消されないこと', () async {
      // 失敗していない購読の正常データがエラーを消すと、失敗した購読の初回
      // データは届かないままなので、画面がローディング表示に戻って抜け出せなく
      // なる(エラーを購読ごとに保持する対策の回帰テスト)
      final target = _buildFixture();
      final exception = Exception('watchAllエラー');

      target.propertyRepository.propertiesController.addError(exception);
      await pumpEventQueue();
      target.recordRepository.recordsController.add([_income(hour: 9)]);
      await pumpEventQueue();

      expect(target.viewModel.loadError, exception);
    });

    test('レコードの購読がError(実装バグ)を流したとき、状態化されず再送出されること', () async {
      // 再送出はStreamSubscriptionのonErrorコールバック内で起きるため、
      // 購読を開始したZoneの未処理エラーとして観測する(そのままだとテスト全体の
      // 失敗になり、どのtest()の失敗として報告されるかも不安定になる)。
      Object? uncaughtError;
      late _Fixture target;
      runZonedGuarded(
        () => target = _buildFixture(),
        (error, stackTrace) => uncaughtError = error,
      );

      target.recordRepository.recordsController.addError(ArgumentError('実装バグ'));
      await pumpEventQueue();

      expect(uncaughtError, isA<ArgumentError>());
      expect(target.viewModel.loadError, isNull);
    });
  });

  group('破棄', () {
    test('disposeしたとき、4本の購読がすべて解除されること', () async {
      final target = _buildFixture();

      target.viewModel.dispose();
      await pumpEventQueue();

      expect(target.recordRepository.recordsController.hasListener, isFalse);
      expect(
        target.categoryRepository.incomeCategoriesController.hasListener,
        isFalse,
      );
      expect(
        target.categoryRepository.expenseCategoriesController.hasListener,
        isFalse,
      );
      expect(
        target.propertyRepository.propertiesController.hasListener,
        isFalse,
      );
    });
  });
}

class _Fixture {
  _Fixture({
    required this.viewModel,
    required this.recordRepository,
    required this.categoryRepository,
    required this.propertyRepository,
  });

  final DailyRecordsViewModel viewModel;
  final FakeRecordRepository recordRepository;
  final FakeCategoryRepository categoryRepository;
  final FakePropertyRepository propertyRepository;
}

_Fixture _buildFixture() {
  final recordRepository = FakeRecordRepository();
  final categoryRepository = FakeCategoryRepository();
  final propertyRepository = FakePropertyRepository();

  return _Fixture(
    viewModel: DailyRecordsViewModel(
      recordRepository: recordRepository,
      categoryRepository: categoryRepository,
      propertyRepository: propertyRepository,
      year: _year,
      month: _month,
      day: _day,
    ),
    recordRepository: recordRepository,
    categoryRepository: categoryRepository,
    propertyRepository: propertyRepository,
  );
}

/// 4本の購読がすべて届いた(読み込み完了の)状態を作る。
Future<_Fixture> _buildLoadedFixture() async {
  final target = _buildFixture();

  target.recordRepository.recordsController.add([]);
  target.categoryRepository.incomeCategoriesController.add([_salary]);
  target.categoryRepository.expenseCategoriesController.add([_food]);
  target.propertyRepository.propertiesController.add([_wallet, _bank]);
  await pumpEventQueue();

  return target;
}

Record _income({required int hour, String? id}) => Record.income(
  id: RecordId(id ?? 'income-$hour'),
  date: RecordDate(DateTime(_year, _month, _day, hour)),
  amount: Amount(1000),
  note: RecordNote('給料日'),
  categoryId: _salary.id,
  propertyId: _wallet.id,
);

Record _expense({required int hour, String? id}) => Record.expense(
  id: RecordId(id ?? 'expense-$hour'),
  date: RecordDate(DateTime(_year, _month, _day, hour)),
  amount: Amount(500),
  note: RecordNote('昼食'),
  categoryId: _food.id,
  propertyId: _wallet.id,
);

Record _transfer({required int hour, String? id}) => Record.transfer(
  id: RecordId(id ?? 'transfer-$hour'),
  date: RecordDate(DateTime(_year, _month, _day, hour)),
  amount: Amount(3000),
  note: RecordNote(''),
  fromPropertyId: _wallet.id,
  toPropertyId: _bank.id,
);
