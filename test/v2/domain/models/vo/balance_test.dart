import 'package:household_accounts/v2/domain/models/vo/balance.dart';
import 'package:household_accounts/v2/domain/models/vo/expense.dart';
import 'package:household_accounts/v2/domain/models/vo/income.dart';
import 'package:test/test.dart';

void main() {
  [
    // (income, expense, expected)
    (3, 2, 1), // balance is positive
    (1, 1, 0), // balance is zero
    (2, 3, -1), // balance is negative
  ].forEach((values) {
    final (income, expense, expected) = values;
    test(
        'Constructor returns normally (Income: ${income}, Expense: ${expense})',
        () {
      final actual = Balance(Income(income), Expense(expense));
      expect(actual.value, equals(expected));
    });
  });
}
