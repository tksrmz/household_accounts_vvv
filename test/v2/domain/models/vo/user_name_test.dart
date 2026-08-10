import 'package:household_accounts/v2/domain/models/vo/user_name.dart';
import 'package:test/test.dart';

void main() {
  group('Constructor', () {
    for (var value in ['a', 'test', 'b' * 20]) {
      test('インスタンスを生成できる ($value)', () {
        final userName = UserNameVo(value);
        expect(userName.value, value);
      });
    }

    for (var value in ['', 'a' * 21]) {
      test('インスタンスを生成できない ($value)', () {
        expect(() => UserNameVo(value), throwsA(isA<AssertionError>()));
      });
    }
  });

  group('isValid', () {
    for (var value in ['a', 'b' * 20]) {
      test('有効なユーザー名 ($value)', () {
        expect(UserNameVo.isValid(value), isTrue);
      });
    }

    for (var value in ['', 'a' * 21]) {
      test('無効なユーザー名 ($value)', () {
        expect(UserNameVo.isValid(value), isFalse);
      });
    }
  });
}
