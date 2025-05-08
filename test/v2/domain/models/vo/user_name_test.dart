import 'package:household_accounts/v2/domain/models/vo/user_name.dart';
import 'package:test/test.dart';

void main() {
  group('Constructor', () {
    [
      'a',
      'test',
      'b' * 20,
    ].forEach((value) {
      test('インスタンスを生成できる ($value)', () {
        final userName = UserNameVo(value);
        expect(userName.value, value);
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
  });

  group('isValid', () {
    [
      'a',
      'b' * 20,
    ].forEach((value) {
      test('有効なユーザー名 ($value)', () {
        expect(UserNameVo.isValid(value), isTrue);
      });
    });

    [
      '',
      'a' * 21,
    ].forEach((value) {
      test('無効なユーザー名 ($value)', () {
        expect(UserNameVo.isValid(value), isFalse);
      });
    });
  });
}
