import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/v2/domain/models/vo/category_name.dart';

void main() {
  group('CategoryNameVo', () {
    test('1文字で作成できること', () {
      const name = CategoryNameVo('A');
      expect(name.value, 'A');
    });

    test('20文字で作成できること', () {
      const name = CategoryNameVo('12345678901234567890');
      expect(name.value, '12345678901234567890');
    });

    test('空文字で作成するとアサーションエラーが発生すること', () {
      expect(() => CategoryNameVo(''), throwsAssertionError);
    });

    test('21文字で作成するとアサーションエラーが発生すること', () {
      expect(
        () => CategoryNameVo('123456789012345678901'),
        throwsAssertionError,
      );
    });
  });
}
