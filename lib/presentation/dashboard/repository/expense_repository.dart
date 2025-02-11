import '../../../entity/expense.dart';

abstract interface class ExpenseRepository {
  /// 指定された年月の支出データを取得する
  Future<List<Expense>> fetchMonthly(DateTime date);
}
