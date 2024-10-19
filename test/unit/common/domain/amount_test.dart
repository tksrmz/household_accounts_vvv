import 'package:household_accounts/common/domain/amount.dart';
import 'package:test/test.dart';

void main() {
  [100, 1, 0, -1, -100].forEach((element) {
    test('Amount should be created with value of $element', () {
      final amount = Amount(element);
      expect(amount.value, element);
    });
  });
}
