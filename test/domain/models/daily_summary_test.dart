import 'package:household_accounts/domain/models/amount.dart';
import 'package:household_accounts/domain/models/category_id.dart';
import 'package:household_accounts/domain/models/daily_summary.dart';
import 'package:household_accounts/domain/models/property_id.dart';
import 'package:household_accounts/domain/models/record.dart';
import 'package:household_accounts/domain/models/record_date.dart';
import 'package:household_accounts/domain/models/record_id.dart';
import 'package:household_accounts/domain/models/record_note.dart';
import 'package:test/test.dart';

void main() {
  Record income(int day, int amount) => Record.income(
    id: RecordId('id'),
    date: RecordDate(DateTime(2026, 8, day)),
    amount: Amount(amount),
    note: RecordNote(''),
    categoryId: CategoryId('category-id'),
    propertyId: PropertyId('property-id'),
  );

  Record expense(int day, int amount) => Record.expense(
    id: RecordId('id'),
    date: RecordDate(DateTime(2026, 8, day)),
    amount: Amount(amount),
    note: RecordNote(''),
    categoryId: CategoryId('category-id'),
    propertyId: PropertyId('property-id'),
  );

  Record transfer(int day, int amount) => Record.transfer(
    id: RecordId('id'),
    date: RecordDate(DateTime(2026, 8, day)),
    amount: Amount(amount),
    note: RecordNote(''),
    fromPropertyId: PropertyId('from'),
    toPropertyId: PropertyId('to'),
  );

  group('byDay', () {
    test('空リストのとき、空のMapになること', () {
      expect(DailySummary.byDay([]), isEmpty);
    });

    test('レコードのない日のとき、Mapにキーが含まれないこと', () {
      final summaries = DailySummary.byDay([income(3, 100)]);

      expect(summaries.keys, [3]);
      expect(summaries.containsKey(2), isFalse);
      expect(summaries.containsKey(4), isFalse);
    });

    test('同じ日に同じ種別が複数あるとき、その種別に合算されること', () {
      final summaries = DailySummary.byDay([
        income(10, 100),
        income(10, 250),
        expense(10, 30),
        expense(10, 70),
        transfer(10, 500),
        transfer(10, 1500),
      ]);

      expect(
        summaries[10],
        const DailySummary(income: 350, expense: 100, transfer: 2000),
      );
    });

    test('振替が含まれるとき、収支と混ざらずtransferへ合算されること', () {
      final summaries = DailySummary.byDay([
        income(5, 1000),
        expense(5, 300),
        transfer(5, 9999),
      ]);

      expect(
        summaries[5],
        const DailySummary(income: 1000, expense: 300, transfer: 9999),
      );
    });

    test('複数の日にまたがるとき、日ごとに分かれて集計されること', () {
      final summaries = DailySummary.byDay([
        income(1, 100),
        expense(15, 200),
        transfer(31, 300),
      ]);

      expect(summaries, {
        1: const DailySummary(income: 100, expense: 0, transfer: 0),
        15: const DailySummary(income: 0, expense: 200, transfer: 0),
        31: const DailySummary(income: 0, expense: 0, transfer: 300),
      });
    });

    test('月末日のレコードのとき、その日のキーで集計されること', () {
      final summaries = DailySummary.byDay([expense(31, 800)]);

      expect(
        summaries[31],
        const DailySummary(income: 0, expense: 800, transfer: 0),
      );
    });

    test('日付の時刻部分が異なるとき、同じ日として合算されること', () {
      final summaries = DailySummary.byDay([
        Record.income(
          id: RecordId('morning'),
          date: RecordDate(DateTime(2026, 8, 7)),
          amount: Amount(100),
          note: RecordNote(''),
          categoryId: CategoryId('category-id'),
          propertyId: PropertyId('property-id'),
        ),
        Record.income(
          id: RecordId('night'),
          date: RecordDate(DateTime(2026, 8, 7, 23, 59, 59)),
          amount: Amount(200),
          note: RecordNote(''),
          categoryId: CategoryId('category-id'),
          propertyId: PropertyId('property-id'),
        ),
      ]);

      expect(
        summaries[7],
        const DailySummary(income: 300, expense: 0, transfer: 0),
      );
    });
  });
}
