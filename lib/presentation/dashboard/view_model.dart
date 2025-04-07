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

  /// 初期化状態
  final _InitStateLifecycle _initStateLifecycle = _InitStateLifecycle();

  /// エラーが発生したかどうか
  bool _hasError = false;

  /// エラーメッセージ
  String get errorMessage => 'エラーが発生しました。時間をおいて再度お試しください。';

  /// 初期化完了後かどうか
  bool get isAfterInitialization => _initStateLifecycle.isInitialized;

  /// 初期化完了前かどうか
  bool get isBeforeInitialization => !isAfterInitialization;

  /// エラーが発生したかどうか
  bool get hasError => _hasError;

  Future<void> init(DateTime date) async {
    try {
      final summary = await summaryModel.fetch(date);
      income = summary.income;
      expense = summary.expense;
    } catch (SummaryModelException) {
      _hasError = true;
    }

    try {
      budgetGraphDataList = await budgetGraphModel.fetch(date);
    } catch (BudgetGraphModelException) {
      _hasError = true;
    }

    _initStateLifecycle._initialize();

    notifyListeners();
  }
}

/// 初期化状態を表す列挙型
enum _InitState {
  /// 初期化されていない状態
  uninitialized,

  /// 初期化された状態
  initialized,
}

/// 初期化状態を管理するクラス
///
/// 初期化状態は[_InitState]に定義されている2つの状態を持つ。
/// これらの状態は、以下の遷移のみが可能である。
///
/// - (初期化状態新規作成時) -> [_InitState.uninitialized]
/// - [_InitState.uninitialized] -> [_InitState.initialized]
class _InitStateLifecycle {
  /// 初期状態[_InitState.uninitialized]を持つインスタンスを生成する。
  _InitStateLifecycle() : _initState = _InitState.uninitialized;

  _InitState _initState;

  /// 初期化された状態かどうか
  bool get isInitialized => _initState == _InitState.initialized;

  /// 初期化されていない状態[_InitState.uninitialized]から、
  /// 初期化された状態[_InitState.initialized]へ遷移する。
  void _initialize() {
    _initState = _InitState.initialized;
  }
}
