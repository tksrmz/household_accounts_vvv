import 'package:household_accounts/domain/models/user_name.dart';
import 'package:test/test.dart';

void main() {
  group('Constructor', () {
    for (var value in ['a', 'test', 'b' * 20]) {
      test('${value.length}文字の文字列のとき、インスタンスを生成できること', () {
        final userName = UserName(value);
        expect(userName.value, value);
      });
    }

    for (var value in ['', 'a' * 21]) {
      test('${value.length}文字の文字列のとき、AssertionErrorが送出されること', () {
        expect(() => UserName(value), throwsA(isA<AssertionError>()));
      });
    }
  });

  group('validate', () {
    test('0文字のとき、エラーメッセージが返ること', () {
      expect(UserName.validate(''), isNotNull);
    });

    test('1文字のとき、nullが返ること', () {
      expect(UserName.validate('a'), isNull);
    });

    test('20文字のとき、nullが返ること', () {
      expect(UserName.validate('a' * 20), isNull);
    });

    test('21文字のとき、エラーメッセージが返ること', () {
      expect(UserName.validate('a' * 21), isNotNull);
    });
  });
}
