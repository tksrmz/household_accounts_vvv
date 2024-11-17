import 'package:household_accounts/feature/dashboard/entity/income.dart';
import 'package:test/test.dart';

void main() {
  group('Constructor', () {
    [0, 100].forEach((element) {
      test('returns normally with value of ${element}', () {
        final actual = Income(element);
        expect(actual.value, element);
      });
    });

    test('throws AssertionError with negative value', () {
      expect(() => Income(-1), throwsA(isA<AssertionError>()));
    });
  });
}
