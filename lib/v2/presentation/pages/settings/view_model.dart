import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../domain/models/vo/user_id.dart';
import '../../../domain/models/vo/user_name.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/public_profile_repository.dart';
import '../../commands/command.dart';

/// 設定画面を表示するためのViewModel
class SettingsViewModel {
  SettingsViewModel({
    required PublicProfileRepository publicProfileRepository,
    required AuthRepository authRepository,
  })  : _publicProfileRepository = publicProfileRepository,
        _authRepository = authRepository {
    init = AsyncCommand(this._init)..call(_authRepository.getCurrentUser().uid);
  }

  /// 初期化コマンド
  late final AsyncCommand<UserIdVo> init;

  /// ユーザー名保存コマンド
  late final AsyncCommand0 save;

  /// ユーザー名の状態を管理する
  late final UserNameFieldState userNameFieldState;

  final PublicProfileRepository _publicProfileRepository;
  final AuthRepository _authRepository;

  Future<void> _init(UserIdVo userId) async {
    UserNameVo userName = await _publicProfileRepository.fetchUserName(userId);
    save = AsyncCommand0(() => this._save(userId));
    userNameFieldState = UserNameFieldState(userName.value, save);
  }

  // TODO このあたりをステートかコマンドに移す
  Future<void> _save(UserIdVo userId) async {
    userNameFieldState._saving();

    try {
      final newUserName = UserNameVo(userNameFieldState.userName);
      await _publicProfileRepository.updateUserName(userId, newUserName);
      userNameFieldState._display();
    } on Exception catch (ex) {
      developer.log(
        'Failed to save a new user name',
        name: 'SettingsViewModel.save',
        level: Level.WARNING.value,
        error: ex,
        stackTrace: StackTrace.current,
      );
      userNameFieldState._savingError();
      // FIXME rethrowをどうにかしたい
      rethrow;
    }
  }
}

/// ユーザー名表示/編集の状態
class UserNameFieldState with ChangeNotifier {
  UserNameFieldState(this._userName, this._save)
      : _stateMachine = _UserNameFieldStateMachine();

  /// 状態管理
  final _UserNameFieldStateMachine _stateMachine;

  /// ユーザー名保存コマンド
  final AsyncCommand0 _save;

  /// ユーザー名
  String _userName;
  String get userName => _userName;

  /// 保存失敗から表示状態へ戻るときに使うユーザー名
  late String _userNameBeforeEditing;

  bool get _isDisplay =>
      _stateMachine._current == _UserNameFieldStateEnum._display;
  bool get isEditing =>
      _stateMachine._current == _UserNameFieldStateEnum._editing;
  bool get isValidationError =>
      _stateMachine._current == _UserNameFieldStateEnum._validationError;

  void startEditing() {
    assert(_isDisplay, '編集を開始できるのは表示状態のときのみ');
    _userNameBeforeEditing = _userName;
    _stateMachine._transitionTo(_UserNameFieldStateEnum._editing);
    notifyListeners();
  }

  void updateUserName(String newName) {
    assert(isEditing || isValidationError, '更新できるのは編集中かバリデーションエラーのときのみ');

    final next;
    if (UserNameVo.isValid(newName)) {
      next = _UserNameFieldStateEnum._editing;
    } else {
      next = _UserNameFieldStateEnum._validationError;
    }

    _userName = newName;
    _stateMachine._transitionTo(next);
    notifyListeners();
  }

  void clearSaveError() {
    // エラーがない状態でクリアされてもデメリットがないためアサートはしない
    _display();
    _save.resetError();
  }

  void _saving() {
    _stateMachine._transitionTo(_UserNameFieldStateEnum._saving);
    // セーブ状態は画面から参照されないため内部の値を更新するだけでViewへ通知しない
  }

  void _savingError() {
    _userName = _userNameBeforeEditing;
    notifyListeners();
  }

  void _display() {
    _stateMachine._transitionTo(_UserNameFieldStateEnum._display);
    notifyListeners();
  }
}

/// [UserNameFieldState]の状態遷移を管理するクラス
class _UserNameFieldStateMachine {
  /// [_UserNameFieldStateEnum._display]を初期状態としてインスタンスを生成
  _UserNameFieldStateMachine() : _current = _UserNameFieldStateEnum._display;

  /// 現在の状態
  _UserNameFieldStateEnum _current;

  /// 状態遷移のルールを記載したマップ
  ///
  /// 鍵：遷移先の状態
  /// 値：許可される遷移元状態の一覧
  static const Map<_UserNameFieldStateEnum, List<_UserNameFieldStateEnum>>
      _ruleMap = {
    _UserNameFieldStateEnum._display: [
      _UserNameFieldStateEnum._saving,
    ],
    _UserNameFieldStateEnum._editing: [
      _UserNameFieldStateEnum._display,
      _UserNameFieldStateEnum._editing,
      _UserNameFieldStateEnum._validationError,
    ],
    _UserNameFieldStateEnum._validationError: [
      _UserNameFieldStateEnum._editing,
    ],
    _UserNameFieldStateEnum._saving: [
      _UserNameFieldStateEnum._editing,
    ],
  };

  /// [_current]から[next]へ遷移する
  void _transitionTo(_UserNameFieldStateEnum next) {
    assert(_ruleMap[next]!.contains(_current), '${_current}から${next}に遷移できません');
    _current = next;
  }
}

enum _UserNameFieldStateEnum {
  _display,
  _editing,
  _validationError,
  _saving,
}
