import 'package:household_accounts/feature/dashboard/entity/expense_category.dart';
import 'package:test/test.dart';

void main() {
  group('Constructor', () {
    group('name', () {
      ['a', '12345678901234567890'].forEach((expected) {
        test('returns normally with name of ${expected}', () {
          final actual = ExpenseCategory(expected, 100);
          expect(actual.name, expected);
        });
      });

      ['', '123456789012345678901'].forEach((errorName) {
        test('throws AssertionError with name of ${errorName}', () {
          expect(
            () => ExpenseCategory(errorName, 100),
            throwsA(isA<AssertionError>()),
          );
        });
      });
    });

    group('budget', () {
      [0, 100].forEach((expected) {
        test('returns normally with budget of ${expected}', () {
          final actual = ExpenseCategory('test', expected);
          expect(actual.budget, expected);
        });
      });

      test('throws AssertionError with negative budget', () {
        expect(
          () => ExpenseCategory('test', -1),
          throwsA(isA<AssertionError>()),
        );
      });
    });
  });
}
