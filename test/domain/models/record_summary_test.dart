import 'package:household_accounts/domain/models/amount.dart';
import 'package:household_accounts/domain/models/category_id.dart';
import 'package:household_accounts/domain/models/property_id.dart';
import 'package:household_accounts/domain/models/record.dart';
import 'package:household_accounts/domain/models/record_date.dart';
import 'package:household_accounts/domain/models/record_id.dart';
import 'package:household_accounts/domain/models/record_note.dart';
import 'package:household_accounts/domain/models/record_summary.dart';
import 'package:test/test.dart';

void main() {
  final date = RecordDate(DateTime(2026, 8, 24));

  Record income(int amount) => Record.income(
    id: RecordId('id'),
    date: date,
    amount: Amount(amount),
    note: RecordNote(''),
    categoryId: CategoryId('category-id'),
    propertyId: PropertyId('property-id'),
  );

  Record expense(int amount) => Record.expense(
    id: RecordId('id'),
    date: date,
    amount: Amount(amount),
    note: RecordNote(''),
    categoryId: CategoryId('category-id'),
    propertyId: PropertyId('property-id'),
  );

  Record transfer(int amount) => Record.transfer(
    id: RecordId('id'),
    date: date,
    amount: Amount(amount),
    note: RecordNote(''),
    fromPropertyId: PropertyId('from'),
    toPropertyId: PropertyId('to'),
  );

  group('from', () {
    test('空リストのとき、income/expense/balanceがすべて0であること', () {
      final summary = RecordSummary.from([]);

      expect(summary.income, 0);
      expect(summary.expense, 0);
      expect(summary.balance, 0);
    });

    test('収入のみのとき、incomeに合計されbalanceが同じ値になること', () {
      final summary = RecordSummary.from([income(100), income(200)]);

      expect(summary.income, 300);
      expect(summary.expense, 0);
      expect(summary.balance, 300);
    });

    test('支出のみのとき、expenseに合計されbalanceが負の値になること', () {
      final summary = RecordSummary.from([expense(100), expense(50)]);

      expect(summary.income, 0);
      expect(summary.expense, 150);
      expect(summary.balance, -150);
    });

    test('収入・支出・振替が混在するとき、収入と支出がそれぞれ合計されること', () {
      final summary = RecordSummary.from([
        income(1000),
        expense(300),
        transfer(9999),
        income(200),
      ]);

      expect(summary.income, 1200);
      expect(summary.expense, 300);
      expect(summary.balance, 900);
    });

    test('振替のみのとき、集計に含まれずincome/expenseが0であること', () {
      final summary = RecordSummary.from([transfer(500), transfer(1000)]);

      expect(summary.income, 0);
      expect(summary.expense, 0);
      expect(summary.balance, 0);
    });

    test('支出が収入を上回るとき、balanceが負になること', () {
      final summary = RecordSummary.from([income(100), expense(300)]);

      expect(summary.balance, -200);
    });
  });
}
