import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/v2/domain/models/expense_category.dart';
import 'package:household_accounts/v2/domain/models/expense_record.dart';
import 'package:household_accounts/v2/domain/models/property.dart';
import 'package:household_accounts/v2/domain/models/vo/budget_amount.dart';
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
  group('ExpenseRecordModel', () {
    late ExpenseCategoryModel category;
    late PropertyModel property;

    setUp(() {
      category = ExpenseCategoryModel(
        id: CategoryIdVo('expense-category-1'),
        name: CategoryNameVo('食費'),
        totalBudget: BudgetAmountVo(50000),
      );
      property = PropertyModel(
        id: PropertyIdVo('property-1'),
        name: PropertyNameVo('現金'),
        amount: PropertyAmountVo(10000),
      );
    });

    test('有効な値で作成できること', () {
      final expenseRecord = ExpenseRecordModel(
        id: RecordIdVo('expense-1'),
        recordDate: RecordDateVo(DateTime(2025, 1, 1)),
        amount: RecordAmountVo(1000),
        note: RecordNoteVo('昼食'),
        category: category,
        property: property,
        hasCheckedOut: false,
      );

      expect(expenseRecord.id.value, 'expense-1');
      expect(expenseRecord.recordDate.value, DateTime(2025, 1, 1));
      expect(expenseRecord.amount.value, 1000);
      expect(expenseRecord.note.value, '昼食');
      expect(expenseRecord.category, category);
      expect(expenseRecord.property, property);
      expect(expenseRecord.hasCheckedOut, false);
    });

    test('チェックアウト済みの支出レコードを作成できること', () {
      final expenseRecord = ExpenseRecordModel(
        id: RecordIdVo('expense-2'),
        recordDate: RecordDateVo(DateTime(2025, 1, 2)),
        amount: RecordAmountVo(2000),
        note: RecordNoteVo('夕食'),
        category: category,
        property: property,
        hasCheckedOut: true,
      );

      expect(expenseRecord.hasCheckedOut, true);
    });

    test('カテゴリと資産が正しく設定されること', () {
      final expenseRecord = ExpenseRecordModel(
        id: RecordIdVo('expense-3'),
        recordDate: RecordDateVo(DateTime(2025, 1, 3)),
        amount: RecordAmountVo(500),
        note: RecordNoteVo('コーヒー'),
        category: category,
        property: property,
        hasCheckedOut: false,
      );

      expect(expenseRecord.category.id.value, 'expense-category-1');
      expect(expenseRecord.category.name.value, '食費');
      expect(expenseRecord.property.id.value, 'property-1');
      expect(expenseRecord.property.name.value, '現金');
    });
  });
}
