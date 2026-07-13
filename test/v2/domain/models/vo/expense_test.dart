import 'package:household_accounts/v2/domain/models/vo/expense.dart';
import 'package:test/test.dart';

void main() {
  for (var value in [0, 100]) {
    test('Constructor returns instance with value of $value.', () {
      final actual = ExpenseVo(value);
      expect(actual.value, equals(value));
    });
  }

  test('Constructor raise error', () {
    expect(() => ExpenseVo(-1), throwsA(isA<AssertionError>()));
  });
}
