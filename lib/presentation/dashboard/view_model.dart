import 'package:flutter/foundation.dart';

import '../../entity/expense.dart';
import '../../entity/income.dart';
import 'model/budget_graph_data_list.dart';
import 'model/summary.dart';

class SummaryViewModel extends ChangeNotifier {
  SummaryViewModel({
    required this.summaryModel,
    required this.budgetGraphModel,
  });

  final SummaryModel summaryModel;
  final BudgetGraphModel budgetGraphModel;

  /// 当該月の総収入
  Income? income;

  /// 当該月の総支出
  Expense? expense;

  /// 当該月の予算データ
  BudgetGraphDataList? budgetGraphDataList;

  /// init()が呼び出されたかどうか
  bool _isInitialized = false;

  /// エラーが発生したかどうか
  bool _hasError = false;

  /// エラーメッセージ
  String get errorMessage => 'エラーが発生しました。時間をおいて再度お試しください。';

  /// init()が呼び出されたかどうか
  bool get isInitialized => _isInitialized;

  /// init()が呼び出される前かどうか
  bool get isNotInitialized => !isInitialized;

  /// エラーが発生したかどうか
  bool get hasError => _hasError;

  Future<void> init(DateTime date) async {
    try {
      final summary = await summaryModel.fetch();
      income = summary.income;
      expense = summary.expense;
    } catch (SummaryModelException) {
      _hasError = true;
    }

    try {
      budgetGraphDataList = await budgetGraphModel.fetch();
    } catch (BudgetGraphModelException) {
      _hasError = true;
    }

    _isInitialized = true;

    notifyListeners();
  }
}
