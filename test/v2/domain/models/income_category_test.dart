import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/v2/domain/models/income_category.dart';
import 'package:household_accounts/v2/domain/models/vo/category_id.dart';
import 'package:household_accounts/v2/domain/models/vo/category_name.dart';

void main() {
  group('IncomeCategoryVo', () {
    test('有効な値で作成できること', () {
      final category = IncomeCategoryVo(
        id: CategoryIdVo('income-1'),
        name: CategoryNameVo('給与'),
      );
      expect(category.id.value, 'income-1');
      expect(category.name.value, '給与');
    });

    test('削除済みカテゴリが定義されていること', () {
      final deleted = IncomeCategoryVo.deleted;
      expect(deleted.id.value, 'deleted-income-category');
      expect(deleted.name.value, '削除済み');
    });
  });
}