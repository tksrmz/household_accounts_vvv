import 'package:household_accounts/feature/dashboard/entity/budget.dart';
import 'package:test/test.dart';

void main() {
  group('Constructor', () {
    [0, 100].forEach((element) {
      test('returns normally with value of ${element}', () {
        final actual = Budget(element);
        expect(actual.value, element);
      });
    });

    test('throws AssertionError with negative value', () {
      expect(() => Budget(-1), throwsA(isA<AssertionError>()));
    });
  });
}
