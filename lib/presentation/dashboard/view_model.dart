import 'package:flutter/foundation.dart';

import '../../entity/expense.dart';
import '../../entity/income.dart';
import 'model/budget_graph_data_list.dart';

class SummaryViewModel extends ChangeNotifier {
  /// 当該月の総収入
  Income? income;

  /// 当該月の総支出
  Expense? expense;

  /// 当該月の予算データ
  BudgetGraphDataList? budgetGraphDataList;

  /// init()が呼び出されたかどうか
  bool _isInitialized = false;

  /// init()が呼び出されたかどうか
  bool get isInitialized => _isInitialized;

  /// init()が呼び出される前かどうか
  bool get isNotInitialized => !isInitialized;

  /// エラーが発生したかどうか
  bool get hasError =>
      isInitialized &&
      (income == null || expense == null || budgetGraphDataList == null);

  Future<void> init() async {
    income = Income(100);
    expense = Expense(70);
    budgetGraphDataList = BudgetGraphDataList([]);
    _isInitialized = true;
    return;
  }
}
