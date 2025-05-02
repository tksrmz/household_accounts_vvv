import 'package:flutter/foundation.dart' as foundation;

import '../../../domain/models/summary.dart';
import '../../../domain/models/vo/expense.dart';
import '../../../domain/models/vo/income.dart';
import '../../../domain/usecases/summary.dart';

/// ダッシュボードのサマリを表示するためのViewModel
///
/// このクラスは、サマリのデータを取得し、UIに表示するためのロジックを持つ。
/// UseCaseのメソッド呼び出しと、状態更新が主な役割である。
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
      _summaryState = _summaryState._success(summary.income, summary.expense);
    } on SummaryUseCaseException catch (ex) {
      print(ex);
      _summaryState = _summaryState._fail();
    } finally {
      notifyListeners();
    }
  }
}

/// ダッシュボードのサマリの状態を表すクラス
///
/// このクラスは、ダッシュボードのサマリの状態を管理する。
/// 状態の適切な遷移と、状態に応じたモデルの値を露出させることが責務。
class SummaryState {
  SummaryState.uninitialized()
      : _initState = _InitState.uninitialized,
        income = Income.empty,
        expense = Expense.empty;

  SummaryState.success(this.income, this.expense)
      : _initState = _InitState.succeeded;

  SummaryState.failed()
      : _initState = _InitState.failed,
        income = Income.empty,
        expense = Expense.empty;

  /// 初期化状態
  late final _InitState _initState;

  /// 当該月の総収入
  final Income income;

  /// 当該月の総支出
  final Expense expense;

  /// 初期化前かどうか
  bool get isUninitialized => _initState == _InitState.uninitialized;

  /// 初期化に失敗したかどうか
  bool get isFailed => _initState == _InitState.failed;

  /// 初期化されていない状態[_InitState.uninitialized]から、
  /// 初期化に成功した状態[_InitState.succeeded]へ遷移する。
  SummaryState _success(Income newIncome, Expense newExpense) {
    assert(
      _initState == _InitState.uninitialized,
      '初期化されていない状態[_InitState.uninitialized]から、'
      '初期化に成功した状態[_InitState.succeeded]へ遷移することはできません。',
    );
    return SummaryState.success(newIncome, newExpense);
  }

  /// 初期化されていない状態[_InitState.uninitialized]から、
  /// 初期化に失敗した状態[_InitState.failed]へ遷移する。
  SummaryState _fail() {
    assert(
      _initState == _InitState.uninitialized,
      '初期化されていない状態[_InitState.uninitialized]から、'
      '初期化に失敗した状態[_InitState.failed]へ遷移することはできません。',
    );
    return SummaryState.failed();
  }
}

/// 初期化状態を表す列挙型
enum _InitState {
  /// 初期化されていない状態
  uninitialized,

  /// 初期化に成功した状態
  succeeded,

  /// 初期化に失敗した状態
  failed,
}
