import 'package:household_accounts/feature/dashboard/entity/expense.dart';
import 'package:test/test.dart';

void main() {
  group('Constructor', () {
    [0, 100].forEach((element) {
      test('returns normally with value of ${element}', () {
        final actual = Expense(element);
        expect(actual.value, element);
      });
    });

    test('throws AssertionError with negative value', () {
      expect(() => Expense(-1), throwsA(isA<AssertionError>()));
    });
  });
}
