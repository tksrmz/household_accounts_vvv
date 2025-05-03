import 'package:household_accounts/v2/domain/models/vo/user_name.dart';
import 'package:test/test.dart';

void main() {
  [
    'a',
    'test',
    'b' * 20,
  ].forEach((value) {
    test('インスタンスを生成できる ($value)', () {
      final budgetName = UserNameVo(value);
      expect(budgetName.value, value);
    });
  });

  [
    '',
    'a' * 21,
  ].forEach((value) {
    test('インスタンスを生成できない ($value)', () {
      expect(() => UserNameVo(value), throwsA(isA<AssertionError>()));
    });
  });
}
