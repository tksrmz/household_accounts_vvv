import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/domain/models/budget.dart';
import 'package:household_accounts/domain/models/category.dart';
import 'package:household_accounts/domain/models/category_id.dart';
import 'package:household_accounts/domain/models/category_name.dart';
import 'package:household_accounts/ui/categories/categories_view_model.dart';
import 'package:household_accounts/utils/result.dart';

import '../../test-util/fake_category_repository.dart';

final _salary = IncomeCategory(
  id: CategoryId('salary'),
  name: CategoryName('給与'),
);
final _bonus = IncomeCategory(
  id: CategoryId('bonus'),
  name: CategoryName('賞与'),
);
final _food = ExpenseCategory(
  id: CategoryId('food'),
  name: CategoryName('食費'),
  budget: Budget(30000),
);

// なぜtestWidgetsではなくtestを使うか:
// CategoriesViewModelは純粋なDartのChangeNotifierであり、Widgetツリーを
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
    test('生成した直後のとき、収入・支出の購読が1回ずつ始まり、どちらも読み込み中であること', () {
      final target = _buildFixture();

      expect(target.repository.watchIncomeCategoriesCallCount, 1);
      expect(target.repository.watchExpenseCategoriesCallCount, 1);
      expect(target.viewModel.isIncomeLoading, isTrue);
      expect(target.viewModel.isExpenseLoading, isTrue);
    });

    test('収入カテゴリだけが届いたとき、収入だけ読み込みが完了し支出は読み込み中のままであること', () async {
      final target = _buildFixture();

      target.repository.incomeCategoriesController.add([_bonus, _salary]);
      await pumpEventQueue();

      expect(target.viewModel.isIncomeLoading, isFalse);
      expect(target.viewModel.incomeCategories, [_bonus, _salary]);
      expect(target.viewModel.isExpenseLoading, isTrue);
    });

    test('支出カテゴリだけが届いたとき、支出だけ読み込みが完了し収入は読み込み中のままであること', () async {
      final target = _buildFixture();

      target.repository.expenseCategoriesController.add([_food]);
      await pumpEventQueue();

      expect(target.viewModel.isExpenseLoading, isFalse);
      expect(target.viewModel.expenseCategories, [_food]);
      expect(target.viewModel.isIncomeLoading, isTrue);
    });

    test('どちらも0件で届いたとき、読み込みが完了し一覧が空であること', () async {
      final target = _buildFixture();

      target.repository.incomeCategoriesController.add([]);
      target.repository.expenseCategoriesController.add([]);
      await pumpEventQueue();

      expect(target.viewModel.isIncomeLoading, isFalse);
      expect(target.viewModel.incomeCategories, isEmpty);
      expect(target.viewModel.isExpenseLoading, isFalse);
      expect(target.viewModel.expenseCategories, isEmpty);
    });

    test('2回目の一覧が発行されたとき、一覧が新しい内容へ更新されること', () async {
      final target = _buildFixture();

      target.repository.incomeCategoriesController.add([_salary]);
      await pumpEventQueue();
      target.repository.incomeCategoriesController.add([_bonus, _salary]);
      await pumpEventQueue();

      expect(target.viewModel.incomeCategories, [_bonus, _salary]);
    });
  });

  group('購読のエラー', () {
    test('支出カテゴリの購読がExceptionを流したとき、支出だけがエラーになり収入の一覧は保たれること', () async {
      final target = _buildFixture();
      final exception = Exception('watchExpenseCategoriesエラー');
      target.repository.incomeCategoriesController.add([_salary]);

      target.repository.expenseCategoriesController.addError(exception);
      await pumpEventQueue();

      expect(target.viewModel.expenseLoadError, exception);
      expect(target.viewModel.incomeLoadError, isNull);
      expect(target.viewModel.incomeCategories, [_salary]);
    });

    test('収入カテゴリの購読がExceptionを流したとき、収入だけがエラーになること', () async {
      final target = _buildFixture();
      final exception = Exception('watchIncomeCategoriesエラー');

      target.repository.incomeCategoriesController.addError(exception);
      await pumpEventQueue();

      expect(target.viewModel.incomeLoadError, exception);
      expect(target.viewModel.expenseLoadError, isNull);
    });

    test('エラーのあとに正常な一覧が発行されたとき、その種別のエラーが解消されること', () async {
      final target = _buildFixture();

      target.repository.expenseCategoriesController.addError(
        Exception('watchExpenseCategoriesエラー'),
      );
      await pumpEventQueue();
      expect(target.viewModel.expenseLoadError, isNotNull);

      target.repository.expenseCategoriesController.add([_food]);
      await pumpEventQueue();

      expect(target.viewModel.expenseLoadError, isNull);
      expect(target.viewModel.expenseCategories, [_food]);
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

      target.repository.incomeCategoriesController.addError(
        ArgumentError('実装バグ'),
      );
      await pumpEventQueue();

      expect(uncaughtError, isA<ArgumentError>());
      expect(target.viewModel.incomeLoadError, isNull);
    });
  });

  group('カテゴリの削除', () {
    test('収入カテゴリの削除を実行したとき、対象のIDが収入カテゴリの削除へ1回だけ渡ること', () async {
      final target = _buildFixture();

      await target.viewModel.deleteIncome.execute(_salary.id);

      expect(target.repository.deleteIncomeCategoryCalls, [_salary.id]);
      expect(target.repository.deleteExpenseCategoryCalls, isEmpty);
    });

    test('支出カテゴリの削除を実行したとき、対象のIDが支出カテゴリの削除へ1回だけ渡ること', () async {
      final target = _buildFixture();

      await target.viewModel.deleteExpense.execute(_food.id);

      expect(target.repository.deleteExpenseCategoryCalls, [_food.id]);
      expect(target.repository.deleteIncomeCategoryCalls, isEmpty);
    });

    test('収入カテゴリの削除が失敗したとき、収入の削除コマンドがエラーになること', () async {
      final target = _buildFixture();
      target.repository.deleteIncomeCategoryResult = Result.error(
        Exception('deleteエラー'),
      );

      await target.viewModel.deleteIncome.execute(_salary.id);

      expect(target.viewModel.deleteIncome.error, isTrue);
    });

    test('支出カテゴリの削除が失敗したとき、支出の削除コマンドがエラーになること', () async {
      final target = _buildFixture();
      target.repository.deleteExpenseCategoryResult = Result.error(
        Exception('deleteエラー'),
      );

      await target.viewModel.deleteExpense.execute(_food.id);

      expect(target.viewModel.deleteExpense.error, isTrue);
    });
  });

  group('破棄', () {
    test('disposeしたとき、収入・支出の購読がどちらも解除されること', () async {
      final target = _buildFixture();

      target.viewModel.dispose();
      await pumpEventQueue();

      expect(target.repository.incomeCategoriesController.hasListener, isFalse);
      expect(
        target.repository.expenseCategoriesController.hasListener,
        isFalse,
      );
    });
  });
}

class _Fixture {
  _Fixture({required this.viewModel, required this.repository});

  final CategoriesViewModel viewModel;
  final FakeCategoryRepository repository;
}

_Fixture _buildFixture() {
  final repository = FakeCategoryRepository();
  return _Fixture(
    viewModel: CategoriesViewModel(categoryRepository: repository),
    repository: repository,
  );
}
