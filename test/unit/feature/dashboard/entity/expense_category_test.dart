import 'package:household_accounts/feature/dashboard/entity/expense_category.dart';
import 'package:household_accounts/feature/dashboard/vo/category_name.dart';
import 'package:test/test.dart';

void main() {
  group('Constructor', () {
    group('budget', () {
      [0, 100].forEach((expected) {
        test('returns normally with budget of ${expected}', () {
          final actual = ExpenseCategory(CategoryName('test'), expected);
          expect(actual.budget, expected);
        });
      });

      test('throws AssertionError with negative budget', () {
        expect(
          () => ExpenseCategory(CategoryName('test'), -1),
          throwsA(isA<AssertionError>()),
        );
      });
    });
  });
}
