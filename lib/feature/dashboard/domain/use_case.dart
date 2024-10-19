import 'package:household_accounts/common/domain/amount.dart';

class DashboardUseCase {
  /// Get summary of this month.
  ///
  /// Summary includes income, expense, and balance.
  Future<Summary> getSummary() {
    throw UnimplementedError();
  }

  /// Get top three budgets of this month.
  ///
  /// The rest of the budgets are grouped into "Others".
  ///
  /// The returned list is sorted by the used amount of the budget in descending order.
  Future<List<Budget>> getTopThreeBudgetsWithOthers() {
    throw UnimplementedError();
  }

  /// Get top three funds of this month.
  ///
  /// The rest of the funds are grouped into "Others".
  ///
  /// The returned list is sorted by the amount of the fund in descending order.
  Future<List<Fund>> getTopThreeFundsWithOthers() {
    throw UnimplementedError();
  }

  /// Get recent ten transactions.
  ///
  /// The returned list is sorted by the date of the transaction in descending order.
  /// Notice that "the date of the transaction" is not the date of the transaction creation.
  /// (e.g. Created at 2021-01-01, but the transaction date is 2020-12-31)
  Future<List<Transaction>> getRecentTenTransactions() {
    throw UnimplementedError();
  }
}

class Summary {
  final Amount income;
  final Amount expense;
  final Amount balance;

  Summary({
    required this.income,
    required this.expense,
  }) : balance = income - expense;
}

class Budget {}

class Fund {}

class Transaction {}
