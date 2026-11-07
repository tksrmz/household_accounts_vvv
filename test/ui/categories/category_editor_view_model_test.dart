import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/domain/models/budget.dart';
import 'package:household_accounts/domain/models/category.dart';
import 'package:household_accounts/domain/models/category_id.dart';
import 'package:household_accounts/domain/models/category_name.dart';
import 'package:household_accounts/ui/categories/category_editor_view_model.dart';
import 'package:household_accounts/utils/result.dart';

import '../../test-util/fake_category_repository.dart';

final _salary = IncomeCategory(
  id: CategoryId('salary'),
  name: CategoryName('給与'),
);
final _food = ExpenseCategory(
  id: CategoryId('food'),
  name: CategoryName('食費'),
  budget: Budget(30000),
);

// なぜCommandの実行状態を網羅的に確かめないか:
// running/completed/errorの振る舞いはCommand自体の責務であり
// test/utils/command_test.dartで固定済みなので、ここでは画面の挙動を
// 説明するのに必要な範囲だけを確かめる。
void main() {
  group('初期状態', () {
    test('追加で生成したとき、収入が選ばれた空欄から始まり、種別を切り替えられ、エラーは出さず保存できないこと', () {
      final target = _buildAdd();

      expect(target.viewModel.isEditing, isFalse);
      expect(target.viewModel.canChangeKind, isTrue);
      expect(target.viewModel.kind, CategoryKind.income);
      expect(target.viewModel.nameInput, '');
      expect(target.viewModel.budgetInput, '');
      expect(target.viewModel.hasNameError, isFalse);
      expect(target.viewModel.hasBudgetError, isFalse);
      expect(target.viewModel.canSave, isFalse);
    });

    test('収入カテゴリの編集で生成したとき、収入が選ばれその名前から始まり、種別を切り替えられず、保存できること', () {
      final target = _buildEditIncome();

      expect(target.viewModel.isEditing, isTrue);
      expect(target.viewModel.canChangeKind, isFalse);
      expect(target.viewModel.kind, CategoryKind.income);
      expect(target.viewModel.nameInput, '給与');
      expect(target.viewModel.canSave, isTrue);
    });

    test('支出カテゴリの編集で生成したとき、支出が選ばれその名前と予算から始まり、種別を切り替えられず、保存できること', () {
      final target = _buildEditExpense();

      expect(target.viewModel.isEditing, isTrue);
      expect(target.viewModel.canChangeKind, isFalse);
      expect(target.viewModel.kind, CategoryKind.expense);
      expect(target.viewModel.nameInput, '食費');
      expect(target.viewModel.budgetInput, '30000');
      expect(target.viewModel.canSave, isTrue);
    });
  });

  group('種別の切り替え', () {
    test('追加で支出を選んだとき、支出に切り替わり通知されること', () {
      final target = _buildAdd();
      var notifyCount = 0;
      target.viewModel.addListener(() => notifyCount++);

      target.viewModel.onKindSelected(CategoryKind.expense);

      expect(target.viewModel.kind, CategoryKind.expense);
      expect(notifyCount, 1);
    });

    test('追加で選択中の種別をもう一度選んだとき、通知されないこと', () {
      final target = _buildAdd();
      var notifyCount = 0;
      target.viewModel.addListener(() => notifyCount++);

      target.viewModel.onKindSelected(CategoryKind.income);

      expect(notifyCount, 0);
    });

    test('収入カテゴリの編集で支出を選んだとき、収入のまま変わらず通知もされないこと', () {
      final target = _buildEditIncome();
      var notifyCount = 0;
      target.viewModel.addListener(() => notifyCount++);

      target.viewModel.onKindSelected(CategoryKind.expense);

      expect(target.viewModel.kind, CategoryKind.income);
      expect(notifyCount, 0);
    });

    test('支出カテゴリの編集で収入を選んだとき、支出のまま変わらないこと', () {
      final target = _buildEditExpense();

      target.viewModel.onKindSelected(CategoryKind.income);

      expect(target.viewModel.kind, CategoryKind.expense);
    });

    test('予算を入力してから収入へ切り替えて支出へ戻したとき、予算の入力が残っていること', () {
      final target = _buildAdd();
      target.viewModel.onKindSelected(CategoryKind.expense);
      target.viewModel.onBudgetChanged('5000');

      target.viewModel.onKindSelected(CategoryKind.income);
      target.viewModel.onKindSelected(CategoryKind.expense);

      expect(target.viewModel.budgetInput, '5000');
    });
  });

  group('カテゴリ名のライブ検証', () {
    test('空欄にしたとき、エラーになり保存できないこと', () {
      final target = _buildEditIncome();

      target.viewModel.onNameChanged('');

      expect(target.viewModel.hasNameError, isTrue);
      expect(target.viewModel.canSave, isFalse);
    });

    test('21文字にしたとき、エラーになり保存できないこと', () {
      final target = _buildEditIncome();

      target.viewModel.onNameChanged('あ' * (CategoryName.maxLength + 1));

      expect(target.viewModel.hasNameError, isTrue);
      expect(target.viewModel.canSave, isFalse);
    });

    test('エラーのあとに20文字へ直したとき、エラーが解消し保存できること', () {
      final target = _buildEditIncome();
      target.viewModel.onNameChanged('');

      target.viewModel.onNameChanged('あ' * CategoryName.maxLength);

      expect(target.viewModel.hasNameError, isFalse);
      expect(target.viewModel.canSave, isTrue);
    });
  });

  group('予算のライブ検証', () {
    // int.tryParseが受け付けてしまう表記(前後の空白・16進・符号)も、
    // 画面の表示と保存される値が食い違うため不正として扱う
    for (final (label, input) in [
      ('空欄', ''),
      ('負の整数', '-1'),
      ('小数', '1234.50'),
      ('数字以外を含む', '12a'),
      ('桁区切りを含む', '100,000'),
      ('前後に空白を含む', ' 12'),
      ('16進表記', '0x10'),
      ('プラス記号付き', '+5'),
      ('intの範囲を超える桁数', '99999999999999999999'),
    ]) {
      test('支出の編集で$label($input)にしたとき、エラーになり保存できないこと', () {
        final target = _buildEditExpense();

        target.viewModel.onBudgetChanged(input);

        expect(target.viewModel.hasBudgetError, isTrue);
        expect(target.viewModel.canSave, isFalse);
      });
    }

    for (final (label, input) in [('ゼロ', '0'), ('正の整数', '12000')]) {
      test('支出の編集で$label($input)にしたとき、エラーにならず保存できること', () {
        final target = _buildEditExpense();

        target.viewModel.onBudgetChanged(input);

        expect(target.viewModel.hasBudgetError, isFalse);
        expect(target.viewModel.canSave, isTrue);
      });
    }

    test('追加で収入を選んでいるとき、予算が空欄でも名前が妥当なら保存できること', () {
      final target = _buildAdd();

      target.viewModel.onNameChanged('給与');

      expect(target.viewModel.canSave, isTrue);
    });

    test('追加で支出を選んでいるとき、予算が空欄なら名前が妥当でも保存できないこと', () {
      final target = _buildAdd();
      target.viewModel.onNameChanged('食費');

      target.viewModel.onKindSelected(CategoryKind.expense);

      expect(target.viewModel.canSave, isFalse);
    });

    test('支出で不正な予算を入力してから収入へ切り替えたとき、保存できること', () {
      final target = _buildAdd();
      target.viewModel.onNameChanged('給与');
      target.viewModel.onKindSelected(CategoryKind.expense);
      target.viewModel.onBudgetChanged('-1');

      target.viewModel.onKindSelected(CategoryKind.income);

      expect(target.viewModel.canSave, isTrue);
    });
  });

  group('通知', () {
    test('追加で妥当な名前と予算を入力し終えたとき、保存できるようになったことが通知されること', () {
      // エラー表示は未入力のときも妥当な入力のときも出ないため、エラーの変化だけを
      // 通知の契機にすると、保存ボタンが押せるようにならない(回帰テスト)
      final target = _buildAdd();
      target.viewModel.onKindSelected(CategoryKind.expense);
      target.viewModel.onNameChanged('食費');
      var notifyCount = 0;
      target.viewModel.addListener(() => notifyCount++);

      target.viewModel.onBudgetChanged('0');

      expect(notifyCount, 1);
      expect(target.viewModel.canSave, isTrue);
    });

    test('判定の変わらない入力が続いたとき、通知されないこと', () {
      final target = _buildEditExpense();
      var notifyCount = 0;
      target.viewModel.addListener(() => notifyCount++);

      target.viewModel.onNameChanged('外食');
      target.viewModel.onBudgetChanged('50000');

      expect(notifyCount, 0);
    });
  });

  group('追加の保存', () {
    test('収入を選んで保存したとき、入力した名前で収入カテゴリが追加されること', () async {
      final target = _buildAdd();
      target.viewModel.onNameChanged('給与');

      await target.viewModel.submit();

      expect(target.repository.addIncomeCategoryCalls, [CategoryName('給与')]);
      expect(target.repository.addExpenseCategoryCalls, isEmpty);
      expect(target.viewModel.save.completed, isTrue);
    });

    test('支出を選んで保存したとき、入力した名前と予算で支出カテゴリが追加されること', () async {
      final target = _buildAdd();
      target.viewModel.onKindSelected(CategoryKind.expense);
      target.viewModel.onNameChanged('食費');
      target.viewModel.onBudgetChanged('30000');

      await target.viewModel.submit();

      expect(target.repository.addExpenseCategoryCalls, [
        (name: CategoryName('食費'), budget: Budget(30000)),
      ]);
      expect(target.repository.addIncomeCategoryCalls, isEmpty);
    });

    test('支出で予算を入力したあと収入へ切り替えて保存したとき、予算を持たない収入カテゴリが追加されること', () async {
      final target = _buildAdd();
      target.viewModel.onKindSelected(CategoryKind.expense);
      target.viewModel.onBudgetChanged('30000');
      target.viewModel.onNameChanged('給与');
      target.viewModel.onKindSelected(CategoryKind.income);

      await target.viewModel.submit();

      expect(target.repository.addIncomeCategoryCalls, [CategoryName('給与')]);
      expect(target.repository.addExpenseCategoryCalls, isEmpty);
    });

    test('何も入力せずに保存したとき、Repositoryを呼ばずカテゴリ名がエラーになること', () async {
      // 保存ボタンは無効化されているが、型境界に不正な値を渡さない防御を確かめる
      final target = _buildAdd();

      await target.viewModel.submit();

      expect(target.repository.addIncomeCategoryCalls, isEmpty);
      expect(target.viewModel.hasNameError, isTrue);
    });

    test('支出で予算を入力せずに保存したとき、Repositoryを呼ばず予算がエラーになること', () async {
      final target = _buildAdd();
      target.viewModel.onKindSelected(CategoryKind.expense);
      target.viewModel.onNameChanged('食費');

      await target.viewModel.submit();

      expect(target.repository.addExpenseCategoryCalls, isEmpty);
      expect(target.viewModel.hasBudgetError, isTrue);
    });

    test('追加が失敗したとき、コマンドがエラーになること', () async {
      final target = _buildAdd();
      target.repository.addIncomeCategoryResult = Result.error(
        Exception('addエラー'),
      );
      target.viewModel.onNameChanged('給与');

      await target.viewModel.submit();

      expect(target.viewModel.save.error, isTrue);
    });
  });

  group('収入カテゴリの編集の保存', () {
    test('名前を変えて保存したとき、新しい名前で収入カテゴリが更新されること', () async {
      final target = _buildEditIncome();
      target.viewModel.onNameChanged('給料');

      await target.viewModel.submit();

      expect(target.repository.updateIncomeCategoryCalls, [
        (id: _salary.id, name: CategoryName('給料')),
      ]);
    });

    test('名前を変えずに保存したとき、Repositoryを呼ばずに成功すること', () async {
      final target = _buildEditIncome();

      await target.viewModel.submit();

      expect(target.repository.updateIncomeCategoryCalls, isEmpty);
      expect(target.repository.addIncomeCategoryCalls, isEmpty);
      expect(target.viewModel.save.completed, isTrue);
    });

    test('更新が失敗したとき、コマンドがエラーになること', () async {
      final target = _buildEditIncome();
      target.repository.updateIncomeCategoryResult = Result.error(
        Exception('updateエラー'),
      );
      target.viewModel.onNameChanged('給料');

      await target.viewModel.submit();

      expect(target.viewModel.save.error, isTrue);
    });
  });

  group('支出カテゴリの編集の保存', () {
    test('名前だけを変えて保存したとき、名前だけがRepositoryへ渡り予算は書かれないこと', () async {
      final target = _buildEditExpense();
      target.viewModel.onNameChanged('外食');

      await target.viewModel.submit();

      expect(target.repository.updateExpenseCategoryCalls, [
        (id: _food.id, name: CategoryName('外食'), budget: null),
      ]);
    });

    test('予算だけを変えて保存したとき、予算だけがRepositoryへ渡り名前は書かれないこと', () async {
      final target = _buildEditExpense();
      target.viewModel.onBudgetChanged('0');

      await target.viewModel.submit();

      expect(target.repository.updateExpenseCategoryCalls, [
        (id: _food.id, name: null, budget: Budget(0)),
      ]);
    });

    test('名前と予算の両方を変えて保存したとき、両方がRepositoryへ渡ること', () async {
      final target = _buildEditExpense();
      target.viewModel.onNameChanged('外食');
      target.viewModel.onBudgetChanged('5000');

      await target.viewModel.submit();

      expect(target.repository.updateExpenseCategoryCalls, [
        (id: _food.id, name: CategoryName('外食'), budget: Budget(5000)),
      ]);
    });

    test('一度変えた入力を元の内容へ戻して保存したとき、Repositoryを呼ばずに成功すること', () async {
      final target = _buildEditExpense();
      target.viewModel.onBudgetChanged('5000');
      target.viewModel.onBudgetChanged('30000');

      await target.viewModel.submit();

      expect(target.repository.updateExpenseCategoryCalls, isEmpty);
      expect(target.repository.addExpenseCategoryCalls, isEmpty);
      expect(target.viewModel.save.completed, isTrue);
    });

    test('更新が失敗したとき、コマンドがエラーになること', () async {
      final target = _buildEditExpense();
      target.repository.updateExpenseCategoryResult = Result.error(
        Exception('updateエラー'),
      );
      target.viewModel.onBudgetChanged('5000');

      await target.viewModel.submit();

      expect(target.viewModel.save.error, isTrue);
    });
  });
}

class _Fixture {
  _Fixture({required this.viewModel, required this.repository});

  final CategoryEditorViewModel viewModel;
  final FakeCategoryRepository repository;
}

_Fixture _buildAdd() {
  final repository = FakeCategoryRepository();
  return _Fixture(
    viewModel: CategoryEditorViewModel.add(categoryRepository: repository),
    repository: repository,
  );
}

_Fixture _buildEditIncome() {
  final repository = FakeCategoryRepository();
  return _Fixture(
    viewModel: CategoryEditorViewModel.editIncome(
      categoryRepository: repository,
      category: _salary,
    ),
    repository: repository,
  );
}

_Fixture _buildEditExpense() {
  final repository = FakeCategoryRepository();
  return _Fixture(
    viewModel: CategoryEditorViewModel.editExpense(
      categoryRepository: repository,
      category: _food,
    ),
    repository: repository,
  );
}
