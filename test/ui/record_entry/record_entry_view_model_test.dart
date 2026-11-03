import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/domain/models/amount.dart';
import 'package:household_accounts/domain/models/category.dart';
import 'package:household_accounts/domain/models/category_id.dart';
import 'package:household_accounts/domain/models/category_name.dart';
import 'package:household_accounts/domain/models/property.dart';
import 'package:household_accounts/domain/models/property_id.dart';
import 'package:household_accounts/domain/models/property_name.dart';
import 'package:household_accounts/domain/models/record_content.dart';
import 'package:household_accounts/domain/models/record_date.dart';
import 'package:household_accounts/domain/models/record_note.dart';
import 'package:household_accounts/ui/record_entry/record_entry_view_model.dart';
import 'package:household_accounts/utils/result.dart';

import '../../test-util/fake_category_repository.dart';
import '../../test-util/fake_property_repository.dart';
import '../../test-util/fake_record_repository.dart';

// 「当日」をテストから固定し、未来日付の判定を実行日に左右されないようにする
final _today = DateTime(2026, 8, 26, 13, 45);

final _salary = IncomeCategory(
  id: CategoryId('salary'),
  name: CategoryName('給与'),
);
final _bonus = IncomeCategory(
  id: CategoryId('bonus'),
  name: CategoryName('賞与'),
);
final _food = ExpenseCategory(id: CategoryId('food'), name: CategoryName('食費'));
final _wallet = Property(id: PropertyId('wallet'), name: PropertyName('財布'));
final _bank = Property(id: PropertyId('bank'), name: PropertyName('銀行'));

// なぜtestWidgetsではなくtestを使うか:
// RecordEntryViewModelは純粋なDartのChangeNotifierであり、Widgetツリーを
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
  group('選択肢の読み込み', () {
    test('生成したとき、収入カテゴリ・支出カテゴリ・資産の購読がそれぞれ1回始まること', () {
      final target = _buildFixture();

      expect(target.categoryRepository.watchIncomeCategoriesCallCount, 1);
      expect(target.categoryRepository.watchExpenseCategoriesCallCount, 1);
      expect(target.propertyRepository.watchAllCallCount, 1);
    });

    test('3本のうち一部しか届いていないとき、isLoadingがtrueのままであること', () async {
      final target = _buildFixture();

      target.categoryRepository.incomeCategoriesController.add([_salary]);
      target.propertyRepository.propertiesController.add([_wallet]);
      await pumpEventQueue();

      expect(target.viewModel.isLoading, isTrue);
    });

    test('3本すべてが届いたとき、isLoadingがfalseになり選択肢が揃うこと', () async {
      final target = await _buildLoadedFixture();

      expect(target.viewModel.isLoading, isFalse);
      expect(target.viewModel.categoryOptions, [
        (id: _salary.id, name: _salary.name.value),
        (id: _bonus.id, name: _bonus.name.value),
      ]);
      expect(target.viewModel.propertyOptions, [_wallet, _bank]);
    });
  });

  group('選択肢の購読のエラー', () {
    test('購読がExceptionを流したとき、optionsErrorにその例外が保持されること', () async {
      final target = _buildFixture();
      final exception = Exception('watchAllエラー');

      target.propertyRepository.propertiesController.addError(exception);
      await pumpEventQueue();

      expect(target.viewModel.optionsError, exception);
    });

    test('エラーのあとに正常な選択肢が発行されたとき、optionsErrorが解消されること', () async {
      final target = _buildFixture();

      target.propertyRepository.propertiesController.addError(
        Exception('watchAllエラー'),
      );
      await pumpEventQueue();
      expect(target.viewModel.optionsError, isNotNull);

      target.propertyRepository.propertiesController.add([_wallet]);
      await pumpEventQueue();

      expect(target.viewModel.optionsError, isNull);
    });

    test('資産の購読が失敗しているとき、カテゴリの正常な発行ではoptionsErrorが解消されないこと', () async {
      // 失敗していない購読の正常データがエラーを消すと、失敗した購読の初回
      // データは届かないままなので、画面がローディング表示に戻って抜け出せなく
      // なる(エラーを購読ごとに保持する対策の回帰テスト)
      final target = _buildFixture();
      final exception = Exception('watchAllエラー');

      target.propertyRepository.propertiesController.addError(exception);
      await pumpEventQueue();
      target.categoryRepository.incomeCategoriesController.add([_salary]);
      await pumpEventQueue();

      expect(target.viewModel.optionsError, exception);
    });

    test('購読がError(実装バグ)を流したとき、状態化されず再送出されること', () async {
      // 再送出はStreamSubscriptionのonErrorコールバック内で起きるため、
      // 購読を開始したZoneの未処理エラーとして観測する(そのままだとテスト全体の
      // 失敗になり、どのtest()の失敗として報告されるかも不安定になる)。
      Object? uncaughtError;
      late _Fixture target;
      runZonedGuarded(
        () => target = _buildFixture(),
        (error, stackTrace) => uncaughtError = error,
      );

      target.categoryRepository.incomeCategoriesController.addError(
        ArgumentError('実装バグ'),
      );
      await pumpEventQueue();

      expect(uncaughtError, isA<ArgumentError>());
      expect(target.viewModel.optionsError, isNull);
    });
  });

  group('選択肢の更新による選択の解除', () {
    test('選択中のカテゴリが新しい一覧から消えたとき、カテゴリの選択が解除されること', () async {
      final target = await _buildLoadedFixture();
      target.viewModel.selectCategory(_bonus.id);

      target.categoryRepository.incomeCategoriesController.add([_salary]);
      await pumpEventQueue();

      expect(target.viewModel.selectedCategoryId, isNull);
    });

    test('選択中のカテゴリが新しい一覧にも残っているとき、カテゴリの選択が保たれること', () async {
      final target = await _buildLoadedFixture();
      target.viewModel.selectCategory(_bonus.id);

      target.categoryRepository.incomeCategoriesController.add([_bonus]);
      await pumpEventQueue();

      expect(target.viewModel.selectedCategoryId, _bonus.id);
    });

    test('選択中の資産と振替先が新しい一覧から消えたとき、どちらの選択も解除されること', () async {
      final target = await _buildLoadedFixture();
      target.viewModel
        ..selectType(RecordEntryType.transfer)
        ..selectProperty(_wallet.id)
        ..selectToProperty(_bank.id);

      target.propertyRepository.propertiesController.add([]);
      await pumpEventQueue();

      expect(target.viewModel.selectedPropertyId, isNull);
      expect(target.viewModel.selectedToPropertyId, isNull);
    });
  });

  group('種別の切り替え', () {
    test('支出へ切り替えたとき、カテゴリの選択が解除され支出カテゴリが選択肢になること', () async {
      final target = await _buildLoadedFixture();
      target.viewModel.selectCategory(_salary.id);

      target.viewModel.selectType(RecordEntryType.expense);

      expect(target.viewModel.selectedCategoryId, isNull);
      expect(target.viewModel.categoryOptions, [
        (id: _food.id, name: _food.name.value),
      ]);
    });

    test('種別を切り替えたとき、資産の選択は保たれること', () async {
      final target = await _buildLoadedFixture();
      target.viewModel.selectProperty(_wallet.id);

      target.viewModel.selectType(RecordEntryType.expense);

      expect(target.viewModel.selectedPropertyId, _wallet.id);
    });

    test('振替から収入へ戻したとき、振替先の選択が解除されること', () async {
      final target = await _buildLoadedFixture();
      target.viewModel
        ..selectType(RecordEntryType.transfer)
        ..selectProperty(_wallet.id)
        ..selectToProperty(_bank.id);

      target.viewModel.selectType(RecordEntryType.income);

      expect(target.viewModel.selectedToPropertyId, isNull);
    });

    test('振替を選んだとき、カテゴリの選択肢が空になること', () async {
      final target = await _buildLoadedFixture();

      target.viewModel.selectType(RecordEntryType.transfer);

      expect(target.viewModel.categoryOptions, isEmpty);
    });
  });

  group('入力のライブ検証', () {
    test('金額に0を入力したとき、検証エラーになり保存できないこと', () async {
      final target = await _buildLoadedFixture();
      _fillIncome(target.viewModel);

      target.viewModel.onAmountChanged('0');

      expect(target.viewModel.hasAmountError, isTrue);
      expect(target.viewModel.canSubmit, isFalse);
    });

    test('不正な金額のあとに正しい金額を入力したとき、検証エラーが解消され保存できること', () async {
      final target = await _buildLoadedFixture();
      _fillIncome(target.viewModel);
      target.viewModel.onAmountChanged('0');

      target.viewModel.onAmountChanged('100');

      expect(target.viewModel.hasAmountError, isFalse);
      expect(target.viewModel.canSubmit, isTrue);
    });

    test('金額が空欄のとき、検証エラーは表示されないが保存はできないこと', () async {
      final target = await _buildLoadedFixture();
      _fillIncome(target.viewModel);

      target.viewModel.onAmountChanged('');

      expect(target.viewModel.hasAmountError, isFalse);
      expect(target.viewModel.canSubmit, isFalse);
    });

    test('カテゴリと資産が未選択のとき、保存できないこと', () async {
      final target = await _buildLoadedFixture();

      target.viewModel.onAmountChanged('100');

      expect(target.viewModel.canSubmit, isFalse);
    });

    test('振替で振替元と振替先に同じ資産を選んだとき、検証エラーになり保存できないこと', () async {
      final target = await _buildLoadedFixture();
      target.viewModel
        ..selectType(RecordEntryType.transfer)
        ..onAmountChanged('100')
        ..selectProperty(_wallet.id)
        ..selectToProperty(_wallet.id);

      expect(target.viewModel.hasSamePropertyError, isTrue);
      expect(target.viewModel.canSubmit, isFalse);
    });

    test('振替で異なる資産を選んだとき、検証エラーにならず保存できること', () async {
      final target = await _buildLoadedFixture();
      target.viewModel
        ..selectType(RecordEntryType.transfer)
        ..onAmountChanged('100')
        ..selectProperty(_wallet.id)
        ..selectToProperty(_bank.id);

      expect(target.viewModel.hasSamePropertyError, isFalse);
      expect(target.viewModel.canSubmit, isTrue);
    });
  });

  group('保存', () {
    test('収入を保存したとき、入力どおりの収入レコードが渡されること', () async {
      final target = await _buildLoadedFixture();
      target.viewModel
        ..selectDate(DateTime(2026, 8, 20, 21, 30))
        ..onAmountChanged('1200')
        ..onNoteChanged('8月分')
        ..selectCategory(_salary.id)
        ..selectProperty(_wallet.id);

      await target.viewModel.submit();

      expect(target.recordRepository.addCallCount, 1);
      expect(
        target.recordRepository.lastAddedRecord,
        RecordContent.income(
          date: RecordDate(DateTime(2026, 8, 20)),
          amount: Amount(1200),
          note: RecordNote('8月分'),
          categoryId: _salary.id,
          propertyId: _wallet.id,
        ),
      );
    });

    test('支出を保存したとき、入力どおりの支出レコードが渡されること', () async {
      final target = await _buildLoadedFixture();
      target.viewModel
        ..selectType(RecordEntryType.expense)
        ..onAmountChanged('980')
        ..onNoteChanged('昼食')
        ..selectCategory(_food.id)
        ..selectProperty(_bank.id);

      await target.viewModel.submit();

      expect(
        target.recordRepository.lastAddedRecord,
        RecordContent.expense(
          date: RecordDate(DateTime(2026, 8, 26)),
          amount: Amount(980),
          note: RecordNote('昼食'),
          categoryId: _food.id,
          propertyId: _bank.id,
        ),
      );
    });

    test('振替を保存したとき、入力どおりの振替レコードが渡されること', () async {
      final target = await _buildLoadedFixture();
      target.viewModel
        ..selectType(RecordEntryType.transfer)
        ..onAmountChanged('5000')
        ..selectProperty(_wallet.id)
        ..selectToProperty(_bank.id);

      await target.viewModel.submit();

      expect(
        target.recordRepository.lastAddedRecord,
        RecordContent.transfer(
          date: RecordDate(DateTime(2026, 8, 26)),
          amount: Amount(5000),
          note: RecordNote(''),
          fromPropertyId: _wallet.id,
          toPropertyId: _bank.id,
        ),
      );
    });

    test('保存に成功したとき、金額とメモだけが空になり日付・種別・選択は保たれること', () async {
      final target = await _buildLoadedFixture();
      target.viewModel
        ..selectType(RecordEntryType.expense)
        ..selectDate(DateTime(2026, 8, 20))
        ..onAmountChanged('980')
        ..onNoteChanged('昼食')
        ..selectCategory(_food.id)
        ..selectProperty(_bank.id);

      await target.viewModel.submit();

      expect(target.viewModel.amountInput, isEmpty);
      expect(target.viewModel.noteInput, isEmpty);
      expect(target.viewModel.type, RecordEntryType.expense);
      expect(target.viewModel.date, DateTime(2026, 8, 20));
      expect(target.viewModel.selectedCategoryId, _food.id);
      expect(target.viewModel.selectedPropertyId, _bank.id);
    });

    test('保存に失敗したとき、入力内容が保たれること', () async {
      final target = await _buildLoadedFixture();
      target.recordRepository.addResult = Result.error(Exception('addエラー'));
      target.viewModel
        ..onAmountChanged('1200')
        ..onNoteChanged('8月分')
        ..selectCategory(_salary.id)
        ..selectProperty(_wallet.id);

      await target.viewModel.submit();

      expect(target.viewModel.submitRecord.error, isTrue);
      expect(target.viewModel.amountInput, '1200');
      expect(target.viewModel.noteInput, '8月分');
    });

    test('保存が完了していないとき、保存できない状態であること', () async {
      final target = await _buildLoadedFixture();
      target.recordRepository.addCompleter = Completer<Result<void>>();
      target.viewModel
        ..onAmountChanged('1200')
        ..selectCategory(_salary.id)
        ..selectProperty(_wallet.id);

      unawaited(target.viewModel.submit());
      await pumpEventQueue();

      expect(target.viewModel.canSubmit, isFalse);
    });

    test('UTF-16で101以上の長さのメモを入力したとき、検証エラーになり保存できない状態であること', () async {
      // TextFieldのmaxLengthは見た目の文字数(書記素)で数えるため、
      // 絵文字などマルチコード単位の文字はドメインの上限(UTF-16)を超えても
      // 入力できてしまう。ドメインと同じ判定でのライブ検証の回帰テスト
      final target = await _buildLoadedFixture();
      target.viewModel
        ..onAmountChanged('1200')
        ..selectCategory(_salary.id)
        ..selectProperty(_wallet.id);

      // 見た目60文字だがUTF-16では120コード単位の絵文字列
      target.viewModel.onNoteChanged('😀' * 60);

      expect(target.viewModel.hasNoteError, isTrue);
      expect(target.viewModel.canSubmit, isFalse);
    });

    test('長すぎるメモのあとに上限以内へ入力し直したとき、検証エラーが解消されること', () async {
      final target = await _buildLoadedFixture();
      target.viewModel.onNoteChanged('a' * 101);
      expect(target.viewModel.hasNoteError, isTrue);

      target.viewModel.onNoteChanged('a' * 100);

      expect(target.viewModel.hasNoteError, isFalse);
    });

    test('未来日付で保存しようとしたとき、検証エラーになり保存が呼ばれないこと', () async {
      final target = await _buildLoadedFixture();
      target.viewModel
        ..selectDate(DateTime(2026, 8, 27))
        ..onAmountChanged('1200')
        ..selectCategory(_salary.id)
        ..selectProperty(_wallet.id);

      await target.viewModel.submit();

      expect(target.viewModel.hasFutureDateError, isTrue);
      expect(target.viewModel.canSubmit, isFalse);
      expect(target.recordRepository.addCallCount, 0);
    });

    test('未来日付のあとに当日以前を選び直したとき、検証エラーが解消され保存できること', () async {
      final target = await _buildLoadedFixture();
      target.viewModel
        ..selectDate(DateTime(2026, 8, 27))
        ..onAmountChanged('1200')
        ..selectCategory(_salary.id)
        ..selectProperty(_wallet.id);
      await target.viewModel.submit();

      target.viewModel.selectDate(DateTime(2026, 8, 26));
      await target.viewModel.submit();

      expect(target.viewModel.hasFutureDateError, isFalse);
      expect(target.recordRepository.addCallCount, 1);
    });
  });

  group('破棄', () {
    test('保存の完了前にdisposeされたとき、完了後の通知でエラーにならないこと', () async {
      // ノート切替はHostごと再生成でVMをdisposeするが、保存中のCommandは
      // VMと独立して完走する。破棄済みChangeNotifierへの通知(assert違反)を
      // しないことの回帰テスト
      final target = await _buildLoadedFixture();
      final completer = Completer<Result<void>>();
      target.recordRepository.addCompleter = completer;
      target.viewModel
        ..onAmountChanged('1200')
        ..selectCategory(_salary.id)
        ..selectProperty(_wallet.id);
      unawaited(target.viewModel.submit());
      await pumpEventQueue();

      target.viewModel.dispose();
      completer.complete(const Result.ok(null));
      await pumpEventQueue();

      expect(target.recordRepository.addCallCount, 1);
    });

    test('disposeしたとき、3本の購読がすべて解除されること', () async {
      final target = _buildFixture();

      target.viewModel.dispose();
      await pumpEventQueue();

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

/// 収入として保存できる最低限の入力を埋める。
void _fillIncome(RecordEntryViewModel viewModel) {
  viewModel
    ..onAmountChanged('100')
    ..selectCategory(_salary.id)
    ..selectProperty(_wallet.id);
}

_Fixture _buildFixture() {
  final recordRepository = FakeRecordRepository();
  final categoryRepository = FakeCategoryRepository();
  final propertyRepository = FakePropertyRepository();

  return _Fixture(
    viewModel: RecordEntryViewModel(
      recordRepository: recordRepository,
      categoryRepository: categoryRepository,
      propertyRepository: propertyRepository,
      clock: () => _today,
    ),
    recordRepository: recordRepository,
    categoryRepository: categoryRepository,
    propertyRepository: propertyRepository,
  );
}

/// 3本の選択肢がすべて届いた(読み込み完了の)状態を作る。
Future<_Fixture> _buildLoadedFixture() async {
  final target = _buildFixture();

  target.categoryRepository.incomeCategoriesController.add([_salary, _bonus]);
  target.categoryRepository.expenseCategoriesController.add([_food]);
  target.propertyRepository.propertiesController.add([_wallet, _bank]);
  await pumpEventQueue();

  return target;
}

class _Fixture {
  _Fixture({
    required this.viewModel,
    required this.recordRepository,
    required this.categoryRepository,
    required this.propertyRepository,
  });

  final RecordEntryViewModel viewModel;
  final FakeRecordRepository recordRepository;
  final FakeCategoryRepository categoryRepository;
  final FakePropertyRepository propertyRepository;
}
