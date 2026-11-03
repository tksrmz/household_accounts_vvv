import 'package:household_accounts/domain/models/amount.dart';
import 'package:household_accounts/domain/models/category_id.dart';
import 'package:household_accounts/domain/models/property_id.dart';
import 'package:household_accounts/domain/models/record_content.dart';
import 'package:household_accounts/domain/models/record_date.dart';
import 'package:household_accounts/domain/models/record_note.dart';
import 'package:test/test.dart';

void main() {
  final date = RecordDate(DateTime(2026, 8, 24));

  group('生成', () {
    test('RecordContent.incomeを生成したとき、指定したフィールドを持つこと', () {
      final content = RecordContent.income(
        date: date,
        amount: Amount(100),
        note: RecordNote('メモ'),
        categoryId: CategoryId('category-id'),
        propertyId: PropertyId('property-id'),
      );

      expect(content, isA<IncomeRecordContent>());
      final income = content as IncomeRecordContent;
      expect(income.amount, Amount(100));
      expect(income.categoryId, CategoryId('category-id'));
      expect(income.propertyId, PropertyId('property-id'));
    });

    test('RecordContent.expenseを生成したとき、指定したフィールドを持つこと', () {
      final content = RecordContent.expense(
        date: date,
        amount: Amount(200),
        note: RecordNote('メモ'),
        categoryId: CategoryId('category-id'),
        propertyId: PropertyId('property-id'),
      );

      expect(content, isA<ExpenseRecordContent>());
      final expense = content as ExpenseRecordContent;
      expect(expense.amount, Amount(200));
      expect(expense.categoryId, CategoryId('category-id'));
      expect(expense.propertyId, PropertyId('property-id'));
    });

    test('RecordContent.transferを生成したとき、指定したフィールドを持つこと', () {
      final content = RecordContent.transfer(
        date: date,
        amount: Amount(300),
        note: RecordNote('メモ'),
        fromPropertyId: PropertyId('from-property-id'),
        toPropertyId: PropertyId('to-property-id'),
      );

      expect(content, isA<TransferRecordContent>());
      final transfer = content as TransferRecordContent;
      expect(transfer.fromPropertyId, PropertyId('from-property-id'));
      expect(transfer.toPropertyId, PropertyId('to-property-id'));
    });

    test('振替の振替元と振替先が同一資産のとき、AssertionErrorが送出されること', () {
      expect(
        () => RecordContent.transfer(
          date: date,
          amount: Amount(100),
          note: RecordNote(''),
          fromPropertyId: PropertyId('same-property-id'),
          toPropertyId: PropertyId('same-property-id'),
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('balanceEffects', () {
    test('収入のとき、対象資産が増える1件であること', () {
      final content = RecordContent.income(
        date: date,
        amount: Amount(100),
        note: RecordNote(''),
        categoryId: CategoryId('category-id'),
        propertyId: PropertyId('property-id'),
      );

      expect(content.balanceEffects, [
        (propertyId: PropertyId('property-id'), delta: 100),
      ]);
    });

    test('支出のとき、対象資産が減る1件であること', () {
      final content = RecordContent.expense(
        date: date,
        amount: Amount(100),
        note: RecordNote(''),
        categoryId: CategoryId('category-id'),
        propertyId: PropertyId('property-id'),
      );

      expect(content.balanceEffects, [
        (propertyId: PropertyId('property-id'), delta: -100),
      ]);
    });

    test('振替のとき、振替元が減り振替先が増える2件がこの順で並ぶこと', () {
      final content = RecordContent.transfer(
        date: date,
        amount: Amount(100),
        note: RecordNote(''),
        fromPropertyId: PropertyId('from-property-id'),
        toPropertyId: PropertyId('to-property-id'),
      );

      expect(content.balanceEffects, [
        (propertyId: PropertyId('from-property-id'), delta: -100),
        (propertyId: PropertyId('to-property-id'), delta: 100),
      ]);
    });
  });
}
