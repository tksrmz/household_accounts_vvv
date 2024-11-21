import 'package:household_accounts/feature/dashboard/vo/category_name.dart';
import 'package:test/test.dart';

void main() {
  group('Constructor', () {
    ['a', '12345678901234567890'].forEach((expected) {
      test('returns normally with name of ${expected}', () {
        final actual = CategoryName(expected);
        expect(actual.value, expected);
      });
    });

    ['', '123456789012345678901'].forEach((errorName) {
      test('throws AssertionError with name of ${errorName}', () {
        expect(
          () => CategoryName(errorName),
          throwsA(isA<AssertionError>()),
        );
      });
    });
  });
}
