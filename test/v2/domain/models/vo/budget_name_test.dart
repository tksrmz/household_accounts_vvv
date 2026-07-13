import 'package:household_accounts/v2/domain/models/vo/budget_name.dart';
import 'package:test/test.dart';

void main() {
  for (var value in [
    'a',
    'test',
    'b' * 20,
  ]) {
    test('インスタンスを生成できる ($value)', () {
      final budgetName = BudgetNameVo(value);
      expect(budgetName.value, value);
    });
  }

  for (var value in [
    '',
    'a' * 21,
  ]) {
    test('インスタンスを生成できない ($value)', () {
      expect(() => BudgetNameVo(value), throwsA(isA<AssertionError>()));
    });
  }
}
