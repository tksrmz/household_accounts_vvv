/// 初期化可能な状態を表すクラス
class InitializableState<T> {
  /// 初期化されていない状態を作成する
  const InitializableState.uninitialized(this.model)
      : _initState = _InitState.uninitialized;

  /// 初期化に成功した状態を作成する
  const InitializableState._succeeded(this.model)
      : _initState = _InitState.succeeded;

  /// 初期化に失敗した状態を作成する
  const InitializableState._failed(this.model) : _initState = _InitState.failed;

  /// 初期化状態
  final _InitState _initState;

  final T model;

  /// 初期化前かどうか
  bool get isUninitialized => _initState == _InitState.uninitialized;

  /// 初期化に失敗したかどうか
  bool get isFailed => _initState == _InitState.failed;

  /// 初期化されていない状態から、初期化に成功した状態へ遷移する。
  InitializableState<T> success(T successValue) {
    assert(
      isUninitialized,
      '初期化に成功した状態へ遷移するには、初期化されていない状態である必要があります。',
    );
    return InitializableState._succeeded(successValue);
  }

  /// 初期化されていない状態から、初期化に失敗した状態へ遷移する。
  InitializableState<T> fail(T failedValue) {
    assert(
      isUninitialized,
      '初期化に失敗した状態へ遷移するには、初期化されていない状態である必要があります。',
    );
    return InitializableState._failed(failedValue);
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
