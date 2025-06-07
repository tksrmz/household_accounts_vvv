import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/v2/domain/models/income_category.dart';
import 'package:household_accounts/v2/domain/models/income_record.dart';
import 'package:household_accounts/v2/domain/models/property.dart';
import 'package:household_accounts/v2/domain/models/vo/category_id.dart';
import 'package:household_accounts/v2/domain/models/vo/category_name.dart';
import 'package:household_accounts/v2/domain/models/vo/property_amount.dart';
import 'package:household_accounts/v2/domain/models/vo/property_id.dart';
import 'package:household_accounts/v2/domain/models/vo/property_name.dart';
import 'package:household_accounts/v2/domain/models/vo/record_amount.dart';
import 'package:household_accounts/v2/domain/models/vo/record_date.dart';
import 'package:household_accounts/v2/domain/models/vo/record_id.dart';
import 'package:household_accounts/v2/domain/models/vo/record_note.dart';

void main() {
  group('IncomeRecordModel', () {
    late IncomeCategoryModel category;
    late PropertyModel property;

    setUp(() {
      category = IncomeCategoryModel(
        id: CategoryIdVo('income-category-1'),
        name: CategoryNameVo('給与'),
      );
      property = PropertyModel(
        id: PropertyIdVo('property-1'),
        name: PropertyNameVo('銀行口座'),
        amount: PropertyAmountVo(100000),
      );
    });

    test('有効な値で作成できること', () {
      final incomeRecord = IncomeRecordModel(
        id: RecordIdVo('income-1'),
        recordDate: RecordDateVo(DateTime(2025, 1, 15)),
        amount: RecordAmountVo(250000),
        note: RecordNoteVo('月給'),
        category: category,
        property: property,
        hasCheckedOut: false,
      );

      expect(incomeRecord.id.value, 'income-1');
      expect(incomeRecord.recordDate.value, DateTime(2025, 1, 15));
      expect(incomeRecord.amount.value, 250000);
      expect(incomeRecord.note.value, '月給');
      expect(incomeRecord.category, category);
      expect(incomeRecord.property, property);
      expect(incomeRecord.hasCheckedOut, false);
    });

    test('チェックアウト済みの収入レコードを作成できること', () {
      final incomeRecord = IncomeRecordModel(
        id: RecordIdVo('income-2'),
        recordDate: RecordDateVo(DateTime(2025, 1, 20)),
        amount: RecordAmountVo(5000),
        note: RecordNoteVo('副業'),
        category: category,
        property: property,
        hasCheckedOut: true,
      );

      expect(incomeRecord.hasCheckedOut, true);
    });

    test('カテゴリと資産が正しく設定されること', () {
      final incomeRecord = IncomeRecordModel(
        id: RecordIdVo('income-3'),
        recordDate: RecordDateVo(DateTime(2025, 1, 25)),
        amount: RecordAmountVo(10000),
        note: RecordNoteVo('ボーナス'),
        category: category,
        property: property,
        hasCheckedOut: false,
      );

      expect(incomeRecord.category.id.value, 'income-category-1');
      expect(incomeRecord.category.name.value, '給与');
      expect(incomeRecord.property.id.value, 'property-1');
      expect(incomeRecord.property.name.value, '銀行口座');
    });
  });
}
