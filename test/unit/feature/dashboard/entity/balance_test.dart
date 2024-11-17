import 'package:household_accounts/feature/dashboard/entity/balance.dart';
import 'package:household_accounts/feature/dashboard/entity/expense.dart';
import 'package:household_accounts/feature/dashboard/entity/income.dart';
import 'package:test/test.dart';

void main() {
  group('Constructor', () {
    [
      (Income(100), Expense(99), 1),
      (Income(100), Expense(100), 0),
      (Income(100), Expense(101), -1),
    ].forEach((element) {
      final (income, expense, expected) = element;
      test(
          'returns normally with income of ${income.value} and expense of ${expense.value}',
          () {
        final actual = Balance(income, expense);
        expect(actual.value, expected);
      });
    });
  });
}
