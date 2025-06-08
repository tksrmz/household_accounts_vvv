import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/v2/domain/models/expense_category.dart';
import 'package:household_accounts/v2/domain/models/vo/budget_amount.dart';
import 'package:household_accounts/v2/domain/models/vo/category_id.dart';
import 'package:household_accounts/v2/domain/models/vo/category_name.dart';

void main() {
  group('ExpenseCategoryModel', () {
    test('有効な値で作成できること', () {
      final category = ExpenseCategoryModel(
        id: CategoryIdVo('expense-1'),
        name: CategoryNameVo('食費'),
        totalBudget: BudgetAmountVo(50000),
      );
      expect(category.id.value, 'expense-1');
      expect(category.name.value, '食費');
      expect(category.totalBudget.value, 50000);
    });

    test('削除済みカテゴリが定義されていること', () {
      final deleted = ExpenseCategoryModel.deleted;
      expect(deleted.id.value, 'deleted-expense-category');
      expect(deleted.name.value, '削除済み');
      expect(deleted.totalBudget.value, 0);
    });
  });
}
