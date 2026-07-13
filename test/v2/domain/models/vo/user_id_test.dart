import 'package:household_accounts/v2/domain/models/vo/user_id.dart';
import 'package:test/test.dart';

void main() {
  for (var value in [
    'a',
    'test',
  ]) {
    test('インスタンスを生成できる ($value)', () {
      final userId = UserIdVo(value);
      expect(userId.value, value);
    });
  }

  for (var value in [
    '',
  ]) {
    test('インスタンスを生成できない ($value)', () {
      expect(() => UserIdVo(value), throwsA(isA<AssertionError>()));
    });
  }
}
