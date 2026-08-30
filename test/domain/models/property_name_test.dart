import 'package:household_accounts/domain/models/property_name.dart';
import 'package:test/test.dart';

// なぜAssertionErrorではなくFormatExceptionを期待するか:
// 誓約はassertではなくthrowで表現しており、リリースビルドでも同じように
// 効くことが仕様である。
void main() {
  group('コンストラクタ', () {
    for (final value in ['a', '財布', 'b' * 20]) {
      test('${value.length}文字の文字列のとき、インスタンスを生成できること', () {
        expect(PropertyName(value).value, value);
      });
    }

    for (final value in ['', 'a' * 21]) {
      test('${value.length}文字の文字列のとき、FormatExceptionが送出されること', () {
        expect(() => PropertyName(value), throwsFormatException);
      });
    }
  });

  group('isValid', () {
    test('コンストラクタの検証条件と判定が一致すること', () {
      expect(PropertyName.isValid(''), isFalse);
      expect(PropertyName.isValid('a'), isTrue);
      expect(PropertyName.isValid('a' * 20), isTrue);
      expect(PropertyName.isValid('a' * 21), isFalse);
    });
  });
}
