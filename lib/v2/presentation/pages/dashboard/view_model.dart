import 'package:flutter/foundation.dart' as foundation;

import '../../../domain/models/summary.dart';
import '../../../domain/models/vo/expense.dart';
import '../../../domain/models/vo/income.dart';
import '../../../domain/usecases/summary.dart';
import 'state.dart';

/// ダッシュボードのサマリを表示するためのViewModel
class SummaryViewModel extends foundation.ChangeNotifier {
  SummaryViewModel({
    required this.summaryUseCase,
    // required this.budgetGraphModel,
  }) : _summaryState = SummaryState.uninitialized();

  final SummaryUseCase summaryUseCase;
  // final BudgetGraphModel budgetGraphModel;

  /// 状態
  SummaryState _summaryState;

  /// 当該月の総収入
  Income? get income => _summaryState.income;

  /// 当該月の総支出
  Expense? get expense => _summaryState.expense;

  // /// 当該月の予算データ
  // BudgetGraphDataList? budgetGraphDataList;

  /// 初期化完了前かどうか
  bool get isBeforeInitialization => _summaryState.isUninitialized;

  /// エラーが発生したかどうか
  bool get hasError => _summaryState.isFailed;

  Future<void> init(DateTime date) async {
    if (!isBeforeInitialization) {
      return;
    }

    try {
      SummaryModel summary = await summaryUseCase.fetch(date);
      _summaryState = _summaryState.success(summary.income, summary.expense);
    } on SummaryUseCaseException catch (ex) {
      print(ex);
      _summaryState = _summaryState.fail();
    } finally {
      notifyListeners();
    }
  }
}
