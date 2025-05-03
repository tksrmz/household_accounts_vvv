import 'package:household_accounts/v2/domain/models/vo/income.dart';
import 'package:test/test.dart';

void main() {
  [0, 100].forEach((value) {
    test('Constructor returns instance with value of ${value}.', () {
      final actual = IncomeVo(value);
      expect(actual.value, equals(value));
    });
  });

  test('Constructor raise error', () {
    expect(() => IncomeVo(-1), throwsA(isA<AssertionError>()));
  });
}
