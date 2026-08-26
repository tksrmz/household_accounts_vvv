import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/domain/models/category.dart';
import 'package:household_accounts/domain/models/category_id.dart';
import 'package:household_accounts/domain/models/property.dart';
import 'package:household_accounts/domain/models/property_id.dart';
import 'package:household_accounts/ui/record_entry/record_entry_screen.dart';
import 'package:household_accounts/ui/record_entry/record_entry_view_model.dart';
import 'package:household_accounts/utils/result.dart';

import '../../test-util/fake_category_repository.dart';
import '../../test-util/fake_property_repository.dart';
import '../../test-util/fake_record_repository.dart';
import '../../test-util/golden_helper.dart';

// 「当日」をテストから固定し、日付の表示と選択範囲を実行日に左右されないようにする
final _today = DateTime(2026, 8, 26, 13, 45);

final _salary = IncomeCategory(id: CategoryId('salary'), name: '給与');
final _food = ExpenseCategory(id: CategoryId('food'), name: '食費');
final _wallet = Property(id: PropertyId('wallet'), name: '財布');
final _bank = Property(id: PropertyId('bank'), name: '銀行');

const _amountLabel = '金額';
const _noteLabel = 'メモ';
const _submitLabel = '登録';
const _submitSucceededMessage = 'レコードを登録しました';
const _submitFailedMessage = 'レコードの登録に失敗しました';

// なぜスナックバーをgoldenで確認しないか:
// ScaffoldMessengerはスナックバーをScaffoldへ出すため、撮影範囲
// (RecordEntryScreenのサブツリー)の外に出る。文言と表示は下の通常の
// testWidgetsで固定する。
void main() {
  group('golden', () {
    late _Fixture fixture;

    testGoldens(
      '選択肢が届くまでローディングが表示されること',
      goldenFileName: 'record_entry_loading',
      builder: () => (fixture = _buildFixture()).screen,
    );

    testGoldens(
      '選択肢の購読が失敗するとエラーメッセージが表示されること',
      goldenFileName: 'record_entry_load_failed',
      builder: () => (fixture = _buildFixture()).screen,
      expectFn: (tester) async {
        fixture.propertyRepository.propertiesController.addError(
          Exception('watchAllエラー'),
        );
        await tester.pump();
      },
    );

    testGoldens(
      '収入を入力するとカテゴリと資産の選択欄が表示されること',
      goldenFileName: 'record_entry_income',
      builder: () => (fixture = _buildFixture()).screen,
      expectFn: (tester) async {
        await _emitOptions(tester, fixture);
        await _fillIncome(tester);
      },
    );

    testGoldens(
      '支出を選ぶと支出カテゴリの選択欄が表示されること',
      goldenFileName: 'record_entry_expense',
      builder: () => (fixture = _buildFixture()).screen,
      expectFn: (tester) async {
        await _emitOptions(tester, fixture);
        await _selectType(tester, '支出');
        await _selectOption(tester, dropdownKey: 'category', label: _food.name);
        await _selectOption(tester, dropdownKey: 'property', label: _bank.name);
        await _enterText(tester, label: _amountLabel, text: '980');
      },
    );

    testGoldens(
      '振替を選ぶと振替元と振替先の選択欄が表示されること',
      goldenFileName: 'record_entry_transfer',
      builder: () => (fixture = _buildFixture()).screen,
      expectFn: (tester) async {
        await _emitOptions(tester, fixture);
        await _selectTransfer(tester, from: _wallet.name, to: _bank.name);
        await _enterText(tester, label: _amountLabel, text: '5000');
      },
    );

    testGoldens(
      '金額に0を入力すると検証エラーが表示され登録ボタンが押下不可になること',
      goldenFileName: 'record_entry_amount_error',
      builder: () => (fixture = _buildFixture()).screen,
      expectFn: (tester) async {
        await _emitOptions(tester, fixture);
        await _fillIncome(tester);
        await _enterText(tester, label: _amountLabel, text: '0');
      },
    );

    testGoldens(
      '振替元と振替先に同じ資産を選ぶと検証エラーが表示されること',
      goldenFileName: 'record_entry_same_property',
      builder: () => (fixture = _buildFixture()).screen,
      expectFn: (tester) async {
        await _emitOptions(tester, fixture);
        await _selectTransfer(tester, from: _wallet.name, to: _wallet.name);
      },
    );

    testGoldens(
      'カテゴリと資産が1件も無いと案内が表示されること',
      goldenFileName: 'record_entry_empty_options',
      builder: () => (fixture = _buildFixture()).screen,
      expectFn: (tester) async {
        await _emitOptions(
          tester,
          fixture,
          incomeCategories: const [],
          expenseCategories: const [],
          properties: const [],
        );
      },
    );

    testGoldens(
      '保存中は入力欄と登録ボタンが無効になること',
      goldenFileName: 'record_entry_submitting',
      builder: () => (fixture = _buildFixture(
        addCompleter: Completer<Result<void>>(),
      )).screen,
      expectFn: (tester) async {
        await _emitOptions(tester, fixture);
        await _fillIncome(tester);
        await tester.tap(_submitButton);
        await tester.pump();
      },
    );
  });

  group('保存', () {
    testWidgets('保存に成功したとき、スナックバーが表示され金額とメモの入力欄が空になること', (tester) async {
      await _pumpScreen(tester);
      await _fillIncome(tester);

      await tester.tap(_submitButton);
      await tester.pumpAndSettle();

      expect(find.text(_submitSucceededMessage), findsOneWidget);
      expect(_textOf(tester, _amountLabel), isEmpty);
      expect(_textOf(tester, _noteLabel), isEmpty);
    });

    testWidgets('保存に成功したとき、カテゴリと資産の選択が保たれること', (tester) async {
      await _pumpScreen(tester);
      await _fillIncome(tester);

      await tester.tap(_submitButton);
      await tester.pumpAndSettle();

      expect(_selectedCategoryId(tester), _salary.id);
      expect(_selectedPropertyId(tester), _wallet.id);
    });

    testWidgets('保存に失敗したとき、スナックバーが表示され入力が保たれること', (tester) async {
      await _pumpScreen(tester, addResult: Result.error(Exception('addエラー')));
      await _fillIncome(tester);

      await tester.tap(_submitButton);
      await tester.pumpAndSettle();

      expect(find.text(_submitFailedMessage), findsOneWidget);
      expect(_textOf(tester, _amountLabel), '1200');
      expect(_textOf(tester, _noteLabel), 'ランチ代');
    });
  });

  group('選択欄', () {
    testWidgets('収入を入力するとき、カテゴリと資産の選択を促す文言が表示されること', (tester) async {
      await _pumpScreen(tester);

      expect(find.text('カテゴリを選択'), findsOneWidget);
      expect(find.text('資産を選択'), findsOneWidget);
    });

    testWidgets('資産が1件だけのときに振替を選ぶと、資産の追加を促す案内が表示されること', (tester) async {
      // 振替は振替元と振替先に異なる資産を要求するため、資産1件では成立しない。
      // 案内が無いと、唯一の資産を2回選んで同一資産エラーへ行き着くしかない
      final fixture = _buildFixture();
      await tester.pumpWidget(
        GoldenPageWrapper(child: Scaffold(body: fixture.screen)),
      );
      await _emitOptions(tester, fixture, properties: [_wallet]);

      await _selectType(tester, '振替');

      expect(find.text('振替には資産が2件必要です。資産を先に登録してください'), findsOneWidget);
    });

    testWidgets('収入カテゴリを選択後に支出へ切り替えたとき、カテゴリの選択が解除され選択を促す文言が再表示されること', (
      tester,
    ) async {
      // FormFieldの内部状態が古い選択値を保持したままだと、支出カテゴリの
      // 一覧に無い収入カテゴリを「選択中」のまま描画しようとして
      // Dropdownのassert違反になる(選択肢の集合でFieldを作り直す対策の回帰テスト)
      await _pumpScreen(tester);
      await _selectOption(tester, dropdownKey: 'category', label: _salary.name);

      await _selectType(tester, '支出');

      expect(tester.takeException(), isNull);
      expect(find.text('カテゴリを選択'), findsOneWidget);
      expect(find.text(_salary.name), findsNothing);
    });

    testWidgets('振替を選んだとき、振替元と振替先の選択を促す文言が表示されること', (tester) async {
      await _pumpScreen(tester);

      await _selectType(tester, '振替');

      expect(find.text('振替元を選択'), findsOneWidget);
      expect(find.text('振替先を選択'), findsOneWidget);
    });
  });

  group('登録ボタン', () {
    testWidgets('必須の入力が揃っていないとき、押下できないこと', (tester) async {
      await _pumpScreen(tester);

      expect(tester.widget<FilledButton>(_submitButton).onPressed, isNull);
    });

    testWidgets('必須の入力が揃ったとき、押下できるようになること', (tester) async {
      await _pumpScreen(tester);

      await _fillIncome(tester);

      expect(tester.widget<FilledButton>(_submitButton).onPressed, isNotNull);
    });
  });
}

final _submitButton = find.widgetWithText(FilledButton, _submitLabel);

class _Fixture {
  _Fixture({
    required this.screen,
    required this.recordRepository,
    required this.categoryRepository,
    required this.propertyRepository,
  });

  final RecordEntryScreen screen;
  final FakeRecordRepository recordRepository;
  final FakeCategoryRepository categoryRepository;
  final FakePropertyRepository propertyRepository;
}

_Fixture _buildFixture({
  Result<void>? addResult,
  Completer<Result<void>>? addCompleter,
}) {
  final recordRepository = FakeRecordRepository()
    ..addResult = addResult ?? const Result.ok(null)
    ..addCompleter = addCompleter;
  final categoryRepository = FakeCategoryRepository();
  final propertyRepository = FakePropertyRepository();

  return _Fixture(
    screen: RecordEntryScreen(
      viewModel: RecordEntryViewModel(
        recordRepository: recordRepository,
        categoryRepository: categoryRepository,
        propertyRepository: propertyRepository,
        clock: () => _today,
      ),
    ),
    recordRepository: recordRepository,
    categoryRepository: categoryRepository,
    propertyRepository: propertyRepository,
  );
}

/// 画面を表示し、選択肢が揃った状態にする。
///
/// スナックバーはScaffoldへ表示されるため、画面をScaffoldで包んで確認できる
/// ようにする(この画面自体はシェルがScaffoldを供給する前提でScaffoldを持たない)。
Future<_Fixture> _pumpScreen(
  WidgetTester tester, {
  Result<void>? addResult,
}) async {
  final fixture = _buildFixture(addResult: addResult);

  await tester.pumpWidget(
    GoldenPageWrapper(child: Scaffold(body: fixture.screen)),
  );
  await _emitOptions(tester, fixture);

  return fixture;
}

/// 選択肢(収入カテゴリ・支出カテゴリ・資産)を流し込む。
///
/// broadcastのStreamControllerは購読前のイベントを配らないため、Widgetを
/// pumpしたあと(ViewModelが購読を始めたあと)に流す必要がある。
Future<void> _emitOptions(
  WidgetTester tester,
  _Fixture fixture, {
  List<IncomeCategory>? incomeCategories,
  List<ExpenseCategory>? expenseCategories,
  List<Property>? properties,
}) async {
  fixture.categoryRepository.incomeCategoriesController.add(
    incomeCategories ?? [_salary],
  );
  fixture.categoryRepository.expenseCategoriesController.add(
    expenseCategories ?? [_food],
  );
  fixture.propertyRepository.propertiesController.add(
    properties ?? [_wallet, _bank],
  );
  await tester.pumpAndSettle();
}

/// 収入として保存できる入力をひととおり埋める。
Future<void> _fillIncome(WidgetTester tester) async {
  await _selectOption(tester, dropdownKey: 'category', label: _salary.name);
  await _selectOption(tester, dropdownKey: 'property', label: _wallet.name);
  await _enterText(tester, label: _amountLabel, text: '1200');
  await _enterText(tester, label: _noteLabel, text: 'ランチ代');
}

/// 振替を選び、振替元と振替先を選択する。
Future<void> _selectTransfer(
  WidgetTester tester, {
  required String from,
  required String to,
}) async {
  await _selectType(tester, '振替');
  await _selectOption(tester, dropdownKey: 'fromProperty', label: from);
  await _selectOption(tester, dropdownKey: 'toProperty', label: to);
}

Future<void> _selectType(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// 選択欄を開き、[label]の選択肢を選ぶ。
///
/// 選択肢のラベルは閉じた選択欄の中にも存在する(DropdownButtonが全項目を
/// ツリーへ保持するため)ので、あとから重ねて表示されるメニュー側を選ぶ。
Future<void> _selectOption(
  WidgetTester tester, {
  required String dropdownKey,
  required String label,
}) async {
  await tester.tap(find.byKey(ValueKey(dropdownKey)));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

Future<void> _enterText(
  WidgetTester tester, {
  required String label,
  required String text,
}) async {
  await tester.enterText(find.widgetWithText(TextField, label), text);
  await tester.pumpAndSettle();
}

String _textOf(WidgetTester tester, String label) => tester
    .widget<TextField>(find.widgetWithText(TextField, label))
    .controller!
    .text;

CategoryId? _selectedCategoryId(WidgetTester tester) => tester
    .widget<DropdownButtonFormField<CategoryId>>(
      find.byType(DropdownButtonFormField<CategoryId>),
    )
    .initialValue;

PropertyId? _selectedPropertyId(WidgetTester tester) => tester
    .widget<DropdownButtonFormField<PropertyId>>(
      find.byType(DropdownButtonFormField<PropertyId>),
    )
    .initialValue;
