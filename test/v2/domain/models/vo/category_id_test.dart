import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/v2/domain/models/vo/category_id.dart';

void main() {
  group('CategoryIdVo', () {
    test('有効なIDで作成できること', () {
      const id = CategoryIdVo('category-123');
      expect(id.value, 'category-123');
    });

    test('空文字で作成するとアサーションエラーが発生すること', () {
      expect(() => CategoryIdVo(''), throwsAssertionError);
    });
  });
}
