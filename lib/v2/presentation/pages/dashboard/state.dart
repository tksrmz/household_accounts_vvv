import '../../../domain/models/vo/expense.dart';
import '../../../domain/models/vo/income.dart';

/// ダッシュボードのサマリの状態を表すクラス
///
/// このクラスは、ダッシュボードのサマリの状態を管理する。
/// 状態の適切な遷移と、状態に応じたモデルの値を露出させることが責務。
class SummaryState {
  /// 初期化されていない状態を作成する
  SummaryState.uninitialized()
      : _initState = _InitState.uninitialized,
        income = Income.empty,
        expense = Expense.empty;

  const SummaryState._success(this.income, this.expense)
      : _initState = _InitState.succeeded;

  const SummaryState._failed()
      : _initState = _InitState.failed,
        income = Income.empty,
        expense = Expense.empty;

  /// 初期化状態
  final _InitState _initState;

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
  SummaryState success(Income newIncome, Expense newExpense) {
    assert(
      _initState == _InitState.uninitialized,
      '初期化されていない状態[_InitState.uninitialized]から、'
      '初期化に成功した状態[_InitState.succeeded]へ遷移することはできません。',
    );
    return SummaryState._success(newIncome, newExpense);
  }

  /// 初期化されていない状態[_InitState.uninitialized]から、
  /// 初期化に失敗した状態[_InitState.failed]へ遷移する。
  SummaryState fail() {
    assert(
      _initState == _InitState.uninitialized,
      '初期化されていない状態[_InitState.uninitialized]から、'
      '初期化に失敗した状態[_InitState.failed]へ遷移することはできません。',
    );
    return SummaryState._failed();
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
