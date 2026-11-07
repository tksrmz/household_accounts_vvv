import 'package:household_accounts/domain/models/budget.dart';
import 'package:test/test.dart';

// なぜAssertionErrorではなくFormatExceptionを期待するか:
// 誓約はassertではなくthrowで表現しており、リリースビルドでも同じように
// 効くことが仕様である。
void main() {
  group('コンストラクタ', () {
    for (final value in [0, 1, 1000000]) {
      test('$valueのとき、インスタンスを生成できること', () {
        expect(Budget(value).value, value);
      });
    }

    test('-1のとき、FormatExceptionが送出されること', () {
      expect(() => Budget(-1), throwsFormatException);
    });
  });

  group('isValid', () {
    test('-1のとき、falseを返すこと', () {
      expect(Budget.isValid(-1), isFalse);
    });

    for (final value in [0, 1]) {
      test('$valueのとき、trueを返すこと', () {
        expect(Budget.isValid(value), isTrue);
      });
    }
  });

  test('同じ値を持つBudget同士は等価であること', () {
    expect(Budget(500), Budget(500));
  });
}
