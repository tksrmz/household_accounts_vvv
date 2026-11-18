import 'package:household_accounts/ui/core/formatter.dart';
import 'package:test/test.dart';

void main() {
  group('simpleCurrency', () {
    const testCases = [(1000, '¥1,000'), (-1000, '-¥1,000'), (0, '¥0')];
    for (final (value, expected) in testCases) {
      test('should be ok with value of $value', () {
        expect(Formatter.simpleCurrency(value), equals(expected));
      });
    }
  });
}
