import 'package:household_accounts/domain/models/amount.dart';
import 'package:household_accounts/domain/models/budget.dart';
import 'package:household_accounts/domain/models/budget_summary.dart';
import 'package:household_accounts/domain/models/category.dart';
import 'package:household_accounts/domain/models/category_id.dart';
import 'package:household_accounts/domain/models/category_name.dart';
import 'package:household_accounts/domain/models/property_id.dart';
import 'package:household_accounts/domain/models/record.dart';
import 'package:household_accounts/domain/models/record_date.dart';
import 'package:household_accounts/domain/models/record_id.dart';
import 'package:household_accounts/domain/models/record_note.dart';
import 'package:test/test.dart';

final _food = _category('food', '食費', 30000);
final _transport = _category('transport', '交通費', 5000);
final _hobby = _category('hobby', '趣味', 10000);

void main() {
  group('from', () {
    test('同じカテゴリの支出が複数あるとき、カテゴリごとに合算されること', () {
      final summary = BudgetSummary.from(
        [_food, _transport],
        [
          _expense('food', 1200),
          _expense('food', 800),
          _expense('transport', 5000),
        ],
      );

      expect(summary.categories, [
        (category: _food, spent: 2000),
        (category: _transport, spent: 5000),
      ]);
      expect(summary.orphanedExpense, 0);
    });

    test('収入と振替が含まれるとき、支出だけが合算されること', () {
      final summary = BudgetSummary.from(
        [_food],
        [_expense('food', 1000), _income('food', 50000), _transfer(3000)],
      );

      expect(summary.categories, [(category: _food, spent: 1000)]);
      expect(summary.orphanedExpense, 0);
    });

    test('支出の無いカテゴリがあるとき、支出額0として渡したカテゴリの並びどおりに含まれること', () {
      final summary = BudgetSummary.from(
        [_food, _hobby, _transport],
        [_expense('transport', 300)],
      );

      expect(summary.categories, [
        (category: _food, spent: 0),
        (category: _hobby, spent: 0),
        (category: _transport, spent: 300),
      ]);
    });

    test('どのカテゴリにも一致しない支出があるとき、参照切れの支出として合算されカテゴリの一覧には現れないこと', () {
      final summary = BudgetSummary.from(
        [_food],
        [
          _expense('food', 1000),
          _expense('deleted-1', 2000),
          _expense('deleted-2', 500),
        ],
      );

      expect(summary.categories, [(category: _food, spent: 1000)]);
      expect(summary.orphanedExpense, 2500);
    });

    test('レコードが0件のとき、すべてのカテゴリの支出額が0で参照切れの支出も0であること', () {
      final summary = BudgetSummary.from([_food, _hobby], []);

      expect(summary.categories, [
        (category: _food, spent: 0),
        (category: _hobby, spent: 0),
      ]);
      expect(summary.orphanedExpense, 0);
    });

    test('カテゴリが0件のとき、カテゴリの一覧は空ですべての支出が参照切れとして合算されること', () {
      final summary = BudgetSummary.from([], [
        _expense('food', 1000),
        _expense('hobby', 200),
      ]);

      expect(summary.categories, isEmpty);
      expect(summary.orphanedExpense, 1200);
    });
  });
}

ExpenseCategory _category(String id, String name, int budget) =>
    ExpenseCategory(
      id: CategoryId(id),
      name: CategoryName(name),
      budget: Budget(budget),
    );

var _sequence = 0;

Record _expense(String categoryId, int amount) => Record.expense(
  id: RecordId('expense-${_sequence++}'),
  date: RecordDate(DateTime(2026, 7, 10)),
  amount: Amount(amount),
  note: RecordNote(''),
  categoryId: CategoryId(categoryId),
  propertyId: PropertyId('property'),
);

Record _income(String categoryId, int amount) => Record.income(
  id: RecordId('income-${_sequence++}'),
  date: RecordDate(DateTime(2026, 7, 10)),
  amount: Amount(amount),
  note: RecordNote(''),
  categoryId: CategoryId(categoryId),
  propertyId: PropertyId('property'),
);

Record _transfer(int amount) => Record.transfer(
  id: RecordId('transfer-${_sequence++}'),
  date: RecordDate(DateTime(2026, 7, 10)),
  amount: Amount(amount),
  note: RecordNote(''),
  fromPropertyId: PropertyId('from'),
  toPropertyId: PropertyId('to'),
);
