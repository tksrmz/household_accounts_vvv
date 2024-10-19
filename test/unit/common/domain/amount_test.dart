import 'package:household_accounts/common/domain/amount.dart';
import 'package:test/test.dart';

void main() {
  [100, 1, 0, -1, -100].forEach((element) {
    test('Amount should be created with value of $element', () {
      final amount = Amount(element);
      expect(amount.value, element);
    });
  });

  test('100 - 50 should be 50', () {
    final amount = Amount(100);
    final other = Amount(50);
    final result = amount - other;
    expect(result.value, 50);
  });
}
