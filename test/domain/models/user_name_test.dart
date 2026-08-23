import 'package:household_accounts/domain/models/user_name.dart';
import 'package:test/test.dart';

// なぜAssertionErrorではなくFormatExceptionを期待するか:
// 誓約はassertではなくthrowで表現しており、リリースビルドでも同じように
// 効くことが仕様である。
void main() {
  group('コンストラクタ', () {
    for (final value in ['a', 'test', 'b' * 20]) {
      test('${value.length}文字の文字列のとき、インスタンスを生成できること', () {
        expect(UserName(value).value, value);
      });
    }

    for (final value in ['', 'a' * 21]) {
      test('${value.length}文字の文字列のとき、FormatExceptionが送出されること', () {
        expect(() => UserName(value), throwsFormatException);
      });
    }
  });
}
