import 'package:household_accounts/common/logic/formatter.dart';
import 'package:test/test.dart';

main() {
  group('date', () {
    test('should be ok with a date', () {
      final date = DateTime(2021, 1, 1);
      expect(Formatter.date(date), equals('Fri, Jan 1, 2021'));
    });
  });

  group('simpleCurrency', () {
    const testCases = [
      (1000, '¥1,000'),
      (-1000, '-¥1,000'),
      (0, '¥0'),
    ];
    for (final (value, expected) in testCases) {
      test('should be ok with value of $value', () {
        expect(Formatter.simpleCurrency(value), equals(expected));
      });
    }
  });
}
