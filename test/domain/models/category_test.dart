import 'package:household_accounts/domain/models/budget.dart';
import 'package:household_accounts/domain/models/category.dart';
import 'package:household_accounts/domain/models/category_id.dart';
import 'package:household_accounts/domain/models/category_name.dart';
import 'package:test/test.dart';

ExpenseCategory _expenseCategory({int budget = 30000}) => ExpenseCategory(
  id: CategoryId('category-id'),
  name: CategoryName('食費'),
  budget: Budget(budget),
);

void main() {
  test('IncomeCategoryを生成したとき、指定したフィールドを持つこと', () {
    final category = IncomeCategory(
      id: CategoryId('category-id'),
      name: CategoryName('給与'),
    );

    expect(category.id, CategoryId('category-id'));
    expect(category.name, CategoryName('給与'));
  });

  test('同じフィールドを持つIncomeCategory同士は等価であること', () {
    final a = IncomeCategory(
      id: CategoryId('category-id'),
      name: CategoryName('給与'),
    );
    final b = IncomeCategory(
      id: CategoryId('category-id'),
      name: CategoryName('給与'),
    );

    expect(a, b);
  });

  test('ExpenseCategoryを生成したとき、指定したフィールドを持つこと', () {
    final category = _expenseCategory();

    expect(category.id, CategoryId('category-id'));
    expect(category.name, CategoryName('食費'));
    expect(category.budget, Budget(30000));
  });

  test('同じフィールドを持つExpenseCategory同士は等価であること', () {
    expect(_expenseCategory(), _expenseCategory());
  });

  test('予算が異なるExpenseCategory同士は等価でないこと', () {
    expect(_expenseCategory(budget: 0), isNot(_expenseCategory(budget: 1)));
  });
}
