import 'package:household_accounts/domain/models/category.dart';
import 'package:household_accounts/domain/models/category_id.dart';
import 'package:test/test.dart';

void main() {
  test('IncomeCategoryを生成したとき、指定したフィールドを持つこと', () {
    final category = IncomeCategory(id: CategoryId('category-id'), name: '給与');

    expect(category.id, CategoryId('category-id'));
    expect(category.name, '給与');
  });

  test('同じフィールドを持つIncomeCategory同士は等価であること', () {
    final a = IncomeCategory(id: CategoryId('category-id'), name: '給与');
    final b = IncomeCategory(id: CategoryId('category-id'), name: '給与');

    expect(a, b);
  });

  test('ExpenseCategoryを生成したとき、指定したフィールドを持つこと', () {
    final category = ExpenseCategory(id: CategoryId('category-id'), name: '食費');

    expect(category.id, CategoryId('category-id'));
    expect(category.name, '食費');
  });

  test('同じフィールドを持つExpenseCategory同士は等価であること', () {
    final a = ExpenseCategory(id: CategoryId('category-id'), name: '食費');
    final b = ExpenseCategory(id: CategoryId('category-id'), name: '食費');

    expect(a, b);
  });
}
