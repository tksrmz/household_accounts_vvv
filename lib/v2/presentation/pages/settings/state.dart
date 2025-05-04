import '../../../domain/models/vo/user_name.dart';

/// 設定画面の状態を表すクラス
class SettingsState {
  /// 初期化されていない状態を作成する
  SettingsState.uninitialized()
      : _initState = _InitStateLifecycle(),
        userName = UserNameVo.empty;

  SettingsState._success(this._initState, this.userName)
      : assert(
          _initState._isSucceeded,
          '初期化に成功した状態でなければなりません。',
        );

  SettingsState._failed(this._initState)
      : assert(
          _initState._isFailed,
          '初期化に失敗した状態でなければなりません。',
        ),
        userName = UserNameVo.empty;

  /// 初期化状態
  final _InitStateLifecycle _initState;

  /// ユーザー名
  final UserNameVo userName;

  /// 初期化前かどうか
  bool get isUninitialized => _initState._isUninitialized;

  /// 初期化に失敗したかどうか
  bool get isFailed => _initState._isFailed;

  /// 初期化に成功した
  SettingsState success(UserNameVo userName) {
    return SettingsState._success(_initState._success(), userName);
  }

  /// 初期化に失敗した
  SettingsState fail() {
    return SettingsState._failed(_initState._fail());
  }
}

/// 初期化状態を表す列挙型
enum _InitState {
  uninitialized,
  succeeded,
  failed,
}

/// 初期化状態のライフサイクルを管理するクラス
class _InitStateLifecycle {
  _InitStateLifecycle() : _state = _InitState.uninitialized;

  _InitStateLifecycle._(_InitState state) : _state = state;

  final _InitState _state;

  bool get _isUninitialized => _state == _InitState.uninitialized;
  bool get _isSucceeded => _state == _InitState.succeeded;
  bool get _isFailed => _state == _InitState.failed;

  _InitStateLifecycle _success() {
    assert(_isUninitialized, '初期化前の状態でなければなりません。');
    return _InitStateLifecycle._(_InitState.succeeded);
  }

  _InitStateLifecycle _fail() {
    assert(_isUninitialized, '初期化前の状態でなければなりません。');
    return _InitStateLifecycle._(_InitState.failed);
  }
}
