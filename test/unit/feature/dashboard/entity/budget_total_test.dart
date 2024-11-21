import 'package:household_accounts/feature/dashboard/entity/budget_total.dart';
import 'package:household_accounts/feature/dashboard/entity/expense_category.dart';
import 'package:household_accounts/feature/dashboard/vo/category_name.dart';
import 'package:test/test.dart';

void main() {
  group('Constructor', () {
    <(List<ExpenseCategory>, int)>[
      // 0 item
      (
        List.empty(),
        0,
      ),
      // 1 item
      (
        [
          ExpenseCategory(CategoryName('test'), 100),
        ],
        100,
      ),
      // more than 1 item
      (
        [
          ExpenseCategory(CategoryName('test1'), 100),
          ExpenseCategory(CategoryName('test2'), 200),
          ExpenseCategory(CategoryName('test3'), 300),
        ],
        600
      )
    ].forEach((element) {
      final (categories, expected) = element;
      test(
          'returns normally with categories whose length is ${categories.length}',
          () {
        final actual = BudgetTotal(categories);
        expect(actual.value, expected);
      });
    });
  });
}
