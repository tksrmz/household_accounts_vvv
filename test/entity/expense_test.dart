import 'package:household_accounts/entity/expense.dart';
import 'package:test/test.dart';

void main() {
  [0, 100].forEach((value) {
    test('Constructor returns instance with value of ${value}.', () {
      final actual = Expense(value);
      expect(actual.value, equals(value));
    });
  });

  test('Constructor raise error', () {
    expect(() => Expense(-1), throwsA(isA<AssertionError>()));
  });
}
