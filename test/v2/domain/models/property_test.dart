import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/v2/domain/models/property.dart';
import 'package:household_accounts/v2/domain/models/vo/property_amount.dart';
import 'package:household_accounts/v2/domain/models/vo/property_id.dart';
import 'package:household_accounts/v2/domain/models/vo/property_name.dart';

void main() {
  group('PropertyVo', () {
    test('有効な値で作成できること', () {
      final property = PropertyVo(
        id: PropertyIdVo('property-1'),
        name: PropertyNameVo('現金'),
        amount: PropertyAmountVo(10000),
      );
      expect(property.id.value, 'property-1');
      expect(property.name.value, '現金');
      expect(property.amount.value, 10000);
    });

    test('削除済み資産が定義されていること', () {
      final deleted = PropertyVo.deleted;
      expect(deleted.id.value, 'deleted-property');
      expect(deleted.name.value, '削除済み');
      expect(deleted.amount.value, 0);
    });
  });
}