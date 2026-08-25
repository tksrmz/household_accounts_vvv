import 'package:household_accounts/domain/models/amount.dart';
import 'package:household_accounts/domain/models/category_id.dart';
import 'package:household_accounts/domain/models/property_id.dart';
import 'package:household_accounts/domain/models/record.dart';
import 'package:household_accounts/domain/models/record_date.dart';
import 'package:household_accounts/domain/models/record_id.dart';
import 'package:household_accounts/domain/models/record_note.dart';
import 'package:test/test.dart';

void main() {
  final date = RecordDate(DateTime(2026, 8, 24));

  group('生成', () {
    test('Record.incomeを生成したとき、指定したフィールドを持つこと', () {
      final record = Record.income(
        id: RecordId('record-id'),
        date: date,
        amount: Amount(100),
        note: RecordNote('メモ'),
        categoryId: CategoryId('category-id'),
        propertyId: PropertyId('property-id'),
      );

      expect(record, isA<IncomeRecord>());
      final income = record as IncomeRecord;
      expect(income.amount, Amount(100));
      expect(income.categoryId, CategoryId('category-id'));
      expect(income.propertyId, PropertyId('property-id'));
    });

    test('Record.expenseを生成したとき、指定したフィールドを持つこと', () {
      final record = Record.expense(
        id: RecordId('record-id'),
        date: date,
        amount: Amount(200),
        note: RecordNote('メモ'),
        categoryId: CategoryId('category-id'),
        propertyId: PropertyId('property-id'),
      );

      expect(record, isA<ExpenseRecord>());
      final expense = record as ExpenseRecord;
      expect(expense.amount, Amount(200));
      expect(expense.categoryId, CategoryId('category-id'));
      expect(expense.propertyId, PropertyId('property-id'));
    });

    test('Record.transferを生成したとき、指定したフィールドを持つこと', () {
      final record = Record.transfer(
        id: RecordId('record-id'),
        date: date,
        amount: Amount(300),
        note: RecordNote('メモ'),
        fromPropertyId: PropertyId('from-property-id'),
        toPropertyId: PropertyId('to-property-id'),
      );

      expect(record, isA<TransferRecord>());
      final transfer = record as TransferRecord;
      expect(transfer.fromPropertyId, PropertyId('from-property-id'));
      expect(transfer.toPropertyId, PropertyId('to-property-id'));
    });
  });

  test('sealed switchで3種すべてを網羅的に扱えること', () {
    final records = <Record>[
      Record.income(
        id: RecordId('id-1'),
        date: date,
        amount: Amount(1),
        note: RecordNote(''),
        categoryId: CategoryId('category-id'),
        propertyId: PropertyId('property-id'),
      ),
      Record.expense(
        id: RecordId('id-2'),
        date: date,
        amount: Amount(1),
        note: RecordNote(''),
        categoryId: CategoryId('category-id'),
        propertyId: PropertyId('property-id'),
      ),
      Record.transfer(
        id: RecordId('id-3'),
        date: date,
        amount: Amount(1),
        note: RecordNote(''),
        fromPropertyId: PropertyId('from'),
        toPropertyId: PropertyId('to'),
      ),
    ];

    final types = records
        .map(
          (record) => switch (record) {
            IncomeRecord() => 'income',
            ExpenseRecord() => 'expense',
            TransferRecord() => 'transfer',
          },
        )
        .toList();

    expect(types, ['income', 'expense', 'transfer']);
  });

  test('振替の振替元と振替先が同一資産のとき、AssertionErrorが送出されること', () {
    expect(
      () => Record.transfer(
        id: RecordId('record-id'),
        date: date,
        amount: Amount(100),
        note: RecordNote(''),
        fromPropertyId: PropertyId('same-property-id'),
        toPropertyId: PropertyId('same-property-id'),
      ),
      throwsA(isA<AssertionError>()),
    );
  });
}
