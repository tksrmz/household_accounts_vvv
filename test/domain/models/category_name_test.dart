import 'package:household_accounts/domain/models/category_name.dart';
import 'package:test/test.dart';

// なぜAssertionErrorではなくFormatExceptionを期待するか:
// 誓約はassertではなくthrowで表現しており、リリースビルドでも同じように
// 効くことが仕様である。
void main() {
  group('コンストラクタ', () {
    for (final value in ['a', '食費', 'b' * 20]) {
      test('${value.length}文字の文字列のとき、インスタンスを生成できること', () {
        expect(CategoryName(value).value, value);
      });
    }

    for (final value in ['', 'a' * 21]) {
      test('${value.length}文字の文字列のとき、FormatExceptionが送出されること', () {
        expect(() => CategoryName(value), throwsFormatException);
      });
    }
  });

  group('isValid', () {
    test('コンストラクタの検証条件と判定が一致すること', () {
      expect(CategoryName.isValid(''), isFalse);
      expect(CategoryName.isValid('a'), isTrue);
      expect(CategoryName.isValid('a' * 20), isTrue);
      expect(CategoryName.isValid('a' * 21), isFalse);
    });
  });
}
