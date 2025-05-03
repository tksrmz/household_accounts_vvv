import '../../../domain/models/vo/expense.dart';
import '../../../domain/models/vo/income.dart';

/// ダッシュボードのサマリの状態を表すクラス
///
/// このクラスは、ダッシュボードのサマリの状態を管理する。
/// 状態の適切な遷移と、状態に応じたモデルの値を露出させることが責務。
class SummaryState {
  /// 初期化されていない状態を作成する
  SummaryState.uninitialized()
      : _initState = _InitStateLifecycle(),
        income = Income.empty,
        expense = Expense.empty;

  SummaryState._success(this._initState, this.income, this.expense)
      : assert(
          _initState._isSucceeded,
          '初期化に成功した状態でなければなりません。',
        );

  SummaryState._failed(this._initState)
      : assert(
          _initState._isFailed,
          '初期化に失敗した状態でなければなりません。',
        ),
        income = Income.empty,
        expense = Expense.empty;

  /// 初期化状態
  final _InitStateLifecycle _initState;

  /// 当該月の総収入
  final Income income;

  /// 当該月の総支出
  final Expense expense;

  /// 初期化前かどうか
  bool get isUninitialized => _initState._isUninitialized;

  /// 初期化に失敗したかどうか
  bool get isFailed => _initState._isFailed;

  /// 初期化に成功した
  SummaryState success(Income newIncome, Expense newExpense) {
    return SummaryState._success(
      _initState._success(),
      newIncome,
      newExpense,
    );
  }

  /// 初期化に失敗した
  SummaryState fail() {
    return SummaryState._failed(_initState._fail());
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

/// 初期化状態を管理するクラス
///
/// 初期化状態は[_InitState]に定義されている2つの状態を持つ。
/// これらの状態は、以下の遷移のみが可能である。
///
/// - (初期化状態新規作成時) -> [_InitState.uninitialized]
/// - [_InitState.uninitialized] -> [_InitState.initialized]
class _InitStateLifecycle {
  /// 初期状態[_InitState.uninitialized]を持つインスタンスを生成する。
  _InitStateLifecycle([this._initState = _InitState.uninitialized]);

  final _InitState _initState;

  /// 初期化前かどうか
  bool get _isUninitialized => _initState == _InitState.uninitialized;

  /// 初期化に成功したかどうか
  bool get _isSucceeded => _initState == _InitState.succeeded;

  /// 初期化に失敗したかどうか
  bool get _isFailed => _initState == _InitState.failed;

  /// 初期化されていない状態[_InitState.uninitialized]から、
  /// 初期化に成功した状態[_InitState.succeeded]へ遷移する。
  _InitStateLifecycle _success() {
    assert(
      _isUninitialized,
      '初期化されていない状態[_InitState.uninitialized]から、'
      '初期化に成功した状態[_InitState.succeeded]へ遷移することはできません。',
    );
    return _InitStateLifecycle(_InitState.succeeded);
  }

  /// 初期化されていない状態[_InitState.uninitialized]から、
  /// 初期化に失敗した状態[_InitState.failed]へ遷移する。
  _InitStateLifecycle _fail() {
    assert(
      _isUninitialized,
      '初期化されていない状態[_InitState.uninitialized]から、'
      '初期化に失敗した状態[_InitState.failed]へ遷移することはできません。',
    );
    return _InitStateLifecycle(_InitState.failed);
  }
}
