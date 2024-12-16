import 'package:household_accounts/entity/income.dart';
import 'package:test/test.dart';

void main() {
  [0, 100].forEach((value) {
    test('Constructor returns instance with value of ${value}.', () {
      final actual = Income(value);
      expect(actual.value, equals(value));
    });
  });

  test('Constructor raise error', () {
    expect(() => Income(-1), throwsA(isA<AssertionError>()));
  });
}
