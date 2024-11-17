import 'package:household_accounts/feature/dashboard/entity/date.dart';
import 'package:test/test.dart';

void main() {
  group('Constructor', () {
    test('default returns normally', () {
      final date = Date(1, 1, 1);
      expect(date.year, isNotNull);
      expect(date.month, isNotNull);
      expect(date.day, isNotNull);
    });

    test('.today() returns today', () {
      final now = DateTime.now();
      final date = Date.today();
      expect(date.year, now.year);
      expect(date.month, now.month);
      expect(date.day, now.day);
    });
  });
}
