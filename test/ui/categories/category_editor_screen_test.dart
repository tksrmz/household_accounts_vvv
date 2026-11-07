import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/domain/models/budget.dart';
import 'package:household_accounts/domain/models/category.dart';
import 'package:household_accounts/domain/models/category_id.dart';
import 'package:household_accounts/domain/models/category_name.dart';
import 'package:household_accounts/ui/categories/category_editor_screen.dart';
import 'package:household_accounts/ui/categories/category_editor_view_model.dart';
import 'package:household_accounts/utils/result.dart';

import '../../test-util/fake_category_repository.dart';
import '../../test-util/golden_helper.dart';

final _salary = IncomeCategory(
  id: CategoryId('salary'),
  name: CategoryName('給与'),
);
final _food = ExpenseCategory(
  id: CategoryId('food'),
  name: CategoryName('食費'),
  budget: Budget(30000),
);

final _nameField = find.widgetWithText(TextField, 'カテゴリ名');
final _budgetField = find.widgetWithText(TextField, '予算');
final _saveButton = find.widgetWithText(ElevatedButton, '登録');

// なぜスナックバーをgoldenで確認しないか:
// ScaffoldMessengerは入れ子のScaffoldのうち最も外側にだけスナックバーを出す。
// 3幅ヘルパーはCategoryEditorScreenのScaffoldを別のScaffoldで包むため、
// スナックバーは撮影範囲の外に出る。文言は下の通常のtestWidgetsで固定する。
void main() {
  group('golden', () {
    testGoldens(
      '追加で開いたとき、収入が選ばれ、空欄のカテゴリ名と押せない登録ボタンが表示されること',
      goldenFileName: 'category_editor_add_income',
      builder: () => _buildAdd().screen,
      // カテゴリ名へのautofocusが効いた状態で撮る
      expectFn: (tester) => tester.pumpAndSettle(),
    );

    testGoldens(
      '追加で支出を選んだとき、予算の入力欄が表示されること',
      goldenFileName: 'category_editor_add_expense',
      builder: () => _buildAdd().screen,
      expectFn: (tester) async {
        await tester.tap(find.text('支出'));
        await tester.pumpAndSettle();
      },
    );

    testGoldens(
      '収入カテゴリの編集で開いたとき、収入が選ばれ編集対象の名前が入力済みで表示されること',
      goldenFileName: 'category_editor_edit_income',
      builder: () => _buildEditIncome().screen,
      expectFn: (tester) => tester.pumpAndSettle(),
    );

    testGoldens(
      '支出カテゴリの編集で開いたとき、支出が選ばれ編集対象の名前と予算が入力済みで表示されること',
      goldenFileName: 'category_editor_edit_expense',
      builder: () => _buildEditExpense().screen,
      expectFn: (tester) => tester.pumpAndSettle(),
    );

    testGoldens(
      'カテゴリ名を空にしたとき、カテゴリ名のエラーが表示され登録ボタンが押せないこと',
      goldenFileName: 'category_editor_name_error',
      builder: () => _buildEditExpense().screen,
      expectFn: (tester) async {
        await tester.enterText(_nameField, '');
        await tester.pumpAndSettle();
      },
    );

    testGoldens(
      '予算を0以上の整数でない値にしたとき、予算のエラーが表示され登録ボタンが押せないこと',
      goldenFileName: 'category_editor_budget_error',
      builder: () => _buildEditExpense().screen,
      expectFn: (tester) async {
        await tester.enterText(_budgetField, '-1');
        await tester.pumpAndSettle();
      },
    );
  });

  group('種別の切り替え', () {
    testWidgets('追加で開いた直後のとき、予算の入力欄は表示されないこと', (tester) async {
      await _pumpScreen(tester, _buildAdd());

      expect(_budgetField, findsNothing);
    });

    testWidgets('追加で予算を入力してから収入へ切り替えて支出へ戻したとき、予算の入力が残っていること', (tester) async {
      await _pumpScreen(tester, _buildAdd());
      await tester.tap(find.text('支出'));
      await tester.pumpAndSettle();
      await tester.enterText(_budgetField, '5000');

      await tester.tap(find.text('収入'));
      await tester.pumpAndSettle();
      expect(_budgetField, findsNothing);
      await tester.tap(find.text('支出'));
      await tester.pumpAndSettle();

      expect(find.text('5000'), findsOneWidget);
    });

    testWidgets('収入カテゴリの編集で支出を押したとき、切り替えボタンは無効表示にならず、予算の入力欄も出ないこと', (
      tester,
    ) async {
      await _pumpScreen(tester, _buildEditIncome());

      await tester.tap(find.text('支出'));
      await tester.pumpAndSettle();

      expect(
        tester.widget<ToggleButtons>(find.byType(ToggleButtons)).onPressed,
        isNotNull,
      );
      expect(_budgetField, findsNothing);
    });
  });

  group('予算の入力', () {
    for (final input in ['1234.50', '1e3', '100,000', '-1']) {
      testWidgets('0以上の整数でない「$input」を入力したとき、入力は書き換えられず、エラーが表示され登録できないこと', (
        tester,
      ) async {
        await _pumpScreen(tester, _buildEditExpense());

        await tester.enterText(_budgetField, input);
        await tester.pump();

        expect(find.text(input), findsOneWidget);
        expect(find.text('予算は0以上の整数で入力してください'), findsOneWidget);
        expect(tester.widget<ElevatedButton>(_saveButton).onPressed, isNull);
      });
    }
  });

  group('登録ボタン', () {
    testWidgets('追加で開いた直後のとき、押下できないこと', (tester) async {
      await _pumpScreen(tester, _buildAdd());

      expect(tester.widget<ElevatedButton>(_saveButton).onPressed, isNull);
    });

    testWidgets('追加でカテゴリ名を入力したとき、押下できるようになること', (tester) async {
      await _pumpScreen(tester, _buildAdd());

      await tester.enterText(_nameField, '給与');
      await tester.pump();

      expect(tester.widget<ElevatedButton>(_saveButton).onPressed, isNotNull);
    });
  });

  group('保存', () {
    testWidgets('保存に成功したとき、エディタが閉じること', (tester) async {
      final fixture = _buildEditExpense();
      await _pumpScreen(tester, fixture);

      await tester.enterText(_budgetField, '5000');
      await tester.tap(_saveButton);
      await tester.pumpAndSettle();

      expect(find.byType(CategoryEditorScreen), findsNothing);
      expect(fixture.repository.updateExpenseCategoryCalls, hasLength(1));
    });

    testWidgets('保存に失敗したとき、スナックバーで失敗が伝えられ、エディタに留まること', (tester) async {
      final fixture = _buildEditExpense();
      fixture.repository.updateExpenseCategoryResult = Result.error(
        Exception('updateエラー'),
      );
      await _pumpScreen(tester, fixture);

      await tester.enterText(_budgetField, '5000');
      await tester.tap(_saveButton);
      await tester.pumpAndSettle();

      expect(find.text('カテゴリの保存に失敗しました'), findsOneWidget);
      expect(find.byType(CategoryEditorScreen), findsOneWidget);
      expect(find.text('5000'), findsOneWidget);
    });
  });
}

class _Fixture {
  _Fixture({required this.screen, required this.repository});

  final CategoryEditorScreen screen;
  final FakeCategoryRepository repository;
}

_Fixture _buildAdd() {
  final repository = FakeCategoryRepository();
  return _Fixture(
    screen: CategoryEditorScreen(
      viewModel: CategoryEditorViewModel.add(categoryRepository: repository),
    ),
    repository: repository,
  );
}

_Fixture _buildEditIncome() {
  final repository = FakeCategoryRepository();
  return _Fixture(
    screen: CategoryEditorScreen(
      viewModel: CategoryEditorViewModel.editIncome(
        categoryRepository: repository,
        category: _salary,
      ),
    ),
    repository: repository,
  );
}

_Fixture _buildEditExpense() {
  final repository = FakeCategoryRepository();
  return _Fixture(
    screen: CategoryEditorScreen(
      viewModel: CategoryEditorViewModel.editExpense(
        categoryRepository: repository,
        category: _food,
      ),
    ),
    repository: repository,
  );
}

/// 一覧から開いたときと同じく、別の画面の上へエディタを積んで表示する
/// (保存の成功で画面が閉じることを確かめるため)。
Future<void> _pumpScreen(WidgetTester tester, _Fixture fixture) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute<void>(builder: (_) => fixture.screen)),
            child: const Text('開く'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('開く'));
  await tester.pumpAndSettle();
}
