import 'package:household_accounts/domain/models/amount.dart';
import 'package:test/test.dart';

// なぜAssertionErrorではなくFormatExceptionを期待するか:
// 誓約はassertではなくthrowで表現しており、リリースビルドでも同じように
// 効くことが仕様である。
void main() {
  group('コンストラクタ', () {
    test('1のとき、インスタンスを生成できること', () {
      expect(Amount(1).value, 1);
    });

    for (final value in [0, -1]) {
      test('$valueのとき、FormatExceptionが送出されること', () {
        expect(() => Amount(value), throwsFormatException);
      });
    }
  });

  group('isValid', () {
    for (final value in [0, -1]) {
      test('$valueのとき、falseを返すこと', () {
        expect(Amount.isValid(value), isFalse);
      });
    }

    for (final value in [1, 2]) {
      test('$valueのとき、trueを返すこと', () {
        expect(Amount.isValid(value), isTrue);
      });
    }
  });
}
