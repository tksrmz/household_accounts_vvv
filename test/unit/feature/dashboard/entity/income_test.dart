import 'package:household_accounts/feature/dashboard/entity/income_total.dart';
import 'package:test/test.dart';

void main() {
  group('Constructor', () {
    [0, 100].forEach((element) {
      test('returns normally with value of ${element}', () {
        final actual = IncomeTotal(element);
        expect(actual.value, element);
      });
    });

    test('throws AssertionError with negative value', () {
      expect(() => IncomeTotal(-1), throwsA(isA<AssertionError>()));
    });
  });
}
