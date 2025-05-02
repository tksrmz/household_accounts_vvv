import 'package:household_accounts/v2/domain/models/vo/budget_name.dart';
import 'package:test/test.dart';

void main() {
  [
    'a',
    'test',
    'b' * 20,
  ].forEach((value) {
    test('インスタンスを生成できる ($value)', () {
      final budgetName = BudgetName(value);
      expect(budgetName.value, value);
    });
  });

  [
    '',
    'a' * 21,
  ].forEach((value) {
    test('インスタンスを生成できない ($value)', () {
      expect(() => BudgetName(value), throwsA(isA<AssertionError>()));
    });
  });
}
