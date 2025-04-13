import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart' as foundation;

import '../../entity/expense.dart';
import '../../entity/income.dart';
import 'model/summary.dart';

class SummaryViewModel extends foundation.ChangeNotifier {
  SummaryViewModel({
    required this.summaryModel,
    // required this.budgetGraphModel,
  });

  final SummaryModel summaryModel;
  // final BudgetGraphModel budgetGraphModel;

  /// 当該月の総収入（内部用）
  Income? _income;

  /// 当該月の総収入
  Income? get income => hasError ? null : _income;

  /// 当該月の総支出（内部用）
  Expense? _expense;

  /// 当該月の総支出
  Expense? get expense => hasError ? null : _expense;

  // /// 当該月の予算データ
  // BudgetGraphDataList? budgetGraphDataList;

  /// 初期化状態
  final _InitStateLifecycle _initStateLifecycle = _InitStateLifecycle();

  /// エラーメッセージ
  String get errorMessage => !hasError ? '' : 'エラーが発生しました。時間をおいて再度お試しください。';

  /// 初期化完了前かどうか
  bool get isBeforeInitialization => _initStateLifecycle.isUninitialized;

  /// エラーが発生したかどうか
  bool get hasError => _initStateLifecycle.isFailed;

  Future<void> init(DateTime date) async {
    final Either<SummaryModelException, Summary> result =
        await Task(() => summaryModel.fetch(date))
            .attempt()
            .map((either) => either.leftMap(cast<SummaryModelException>))
            .run();

    result.fold(
      (exception) {
        print(exception);
        _initStateLifecycle._fail();
        notifyListeners();
      },
      (summary) {
        _income = summary.income;
        _expense = summary.expense;
        _initStateLifecycle._success();
        notifyListeners();
      },
    );
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
  _InitStateLifecycle() : _initState = _InitState.uninitialized;

  _InitState _initState;

  /// 初期化前かどうか
  bool get isUninitialized => _initState == _InitState.uninitialized;

  /// 初期化に失敗したかどうか
  bool get isFailed => _initState == _InitState.failed;

  /// 初期化されていない状態[_InitState.uninitialized]から、
  /// 初期化に成功した状態[_InitState.succeeded]へ遷移する。
  void _success() {
    assert(
      _initState == _InitState.uninitialized,
      '初期化されていない状態[_InitState.uninitialized]から、'
      '初期化に成功した状態[_InitState.succeeded]へ遷移することはできません。',
    );
    _initState = _InitState.succeeded;
  }

  /// 初期化されていない状態[_InitState.uninitialized]から、
  /// 初期化に失敗した状態[_InitState.failed]へ遷移する。
  void _fail() {
    assert(
      _initState == _InitState.uninitialized,
      '初期化されていない状態[_InitState.uninitialized]から、'
      '初期化に失敗した状態[_InitState.failed]へ遷移することはできません。',
    );
    _initState = _InitState.failed;
  }
}
