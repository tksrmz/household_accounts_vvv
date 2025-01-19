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

  /// エラーメッセージ
  String get errorMessage => 'エラーが発生しました。時間をおいて再度お試しください。';

  /// init()が呼び出されたかどうか
  bool get isInitialized => _isInitialized;

  /// init()が呼び出される前かどうか
  bool get isNotInitialized => !isInitialized;

  /// エラーが発生したかどうか
  bool get hasError =>
      isInitialized &&
      (income == null || expense == null || budgetGraphDataList == null);

  Future<void> init() async {
    final summary = await summaryModel.fetch();
    income = summary.income;
    expense = summary.expense;

    budgetGraphDataList = await budgetGraphModel.fetch();

    _isInitialized = true;
  }
}
