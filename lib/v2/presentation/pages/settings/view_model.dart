import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../domain/models/vo/user_id.dart';
import '../../../domain/models/vo/user_name.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/public_profile_repository.dart';
import '../../commands/command.dart';

/// 設定画面を表示するためのViewModel
class SettingsViewModel with ChangeNotifier {
  SettingsViewModel({
    required PublicProfileRepository publicProfileRepository,
    required AuthRepository authRepository,
  })  : _publicProfileRepository = publicProfileRepository,
        _authRepository = authRepository,
        userNameFieldState = UserNameFieldState(UserNameVo.empty.value) {
    init = AsyncCommand(this._init)..call(_authRepository.getCurrentUser().uid);
    save = AsyncCommand(this._save);
  }

  /// 初期化コマンド
  late final AsyncCommand<UserIdVo> init;

  /// ユーザー名保存コマンド
  late final AsyncCommand<UserIdVo> save;

  /// ユーザー名の状態を管理する
  UserNameFieldState userNameFieldState;

  final PublicProfileRepository _publicProfileRepository;
  final AuthRepository _authRepository;

  Future<void> _init(UserIdVo userId) async {
    try {
      UserNameVo userName =
          await _publicProfileRepository.fetchUserName(userId);
      userNameFieldState = UserNameFieldState(userName.value);
    } on Exception catch (ex) {
      developer.log(
        'Failed to fetch user name',
        name: 'SettingsViewModel._init',
        level: Level.WARNING.value,
        error: ex,
        stackTrace: StackTrace.current,
      );
      // FIXME rethrowをどうにかしたい
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  /// 保存失敗から表示状態へ戻るときに使うユーザー名
  late String _userNameBeforeEditing;

  // TODO このあたりをステートかコマンドに移す
  void startEditing() {
    _userNameBeforeEditing = userNameFieldState.userName;
    userNameFieldState = userNameFieldState._editing();
    notifyListeners();
  }

  void updateUserName(String newName) {
    userNameFieldState = userNameFieldState._editing(newName);
    notifyListeners();
  }

  Future<void> _save(UserIdVo userId) async {
    userNameFieldState = userNameFieldState._saving();
    notifyListeners();

    try {
      final newUserName = UserNameVo(userNameFieldState.userName);
      await _publicProfileRepository.updateUserName(userId, newUserName);
      userNameFieldState = userNameFieldState._display();
    } on Exception catch (ex) {
      developer.log(
        'Failed to save a new user name',
        name: 'SettingsViewModel.save',
        level: Level.WARNING.value,
        error: ex,
        stackTrace: StackTrace.current,
      );
      userNameFieldState = userNameFieldState._savingError(
        _userNameBeforeEditing,
      );
      // FIXME rethrowをどうにかしたい
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  void clearSaveError() {
    userNameFieldState = userNameFieldState._display();
    notifyListeners();
  }
}

class UserNameFieldState {
  UserNameFieldState(this.userName)
      : _stateMachine = _UserNameFieldStateMachine();

  /// [UserNameFieldState]内からの使用限定
  UserNameFieldState._(this.userName, this._stateMachine);

  final _UserNameFieldStateMachine _stateMachine;
  final String userName;

  bool get _isDisplay =>
      _stateMachine._current == _UserNameFieldStateEnum._display;
  bool get isEditing =>
      _stateMachine._current == _UserNameFieldStateEnum._editing;
  bool get isValidationError =>
      _stateMachine._current == _UserNameFieldStateEnum._validationError;
  bool get _isSaving =>
      _stateMachine._current == _UserNameFieldStateEnum._saving;
  bool get isSavingError =>
      _stateMachine._current == _UserNameFieldStateEnum._savingError;

  UserNameFieldState _editing([String? newValue]) {
    assert(
      _isDisplay || isEditing || isValidationError,
      '表示中の状態、編集中、バリデーションエラー状態からのみ編集状態に遷移できます。',
    );

    if (newValue == null || UserNameVo.isValid(newValue)) {
      return _copyWith(
        newUserName: newValue,
        newMachine: _stateMachine
          .._transitionTo(_UserNameFieldStateEnum._editing),
      );
    }

    return _validationError(newValue);
  }

  UserNameFieldState _validationError(String newValue) {
    assert(
      isEditing,
      '編集中の状態からのみバリデーションエラー状態に遷移できます。',
    );
    return _copyWith(
      newUserName: newValue,
      newMachine: _stateMachine
        .._transitionTo(_UserNameFieldStateEnum._validationError),
    );
  }

  UserNameFieldState _saving() {
    assert(
      isEditing,
      '編集中の状態からのみ保存状態に遷移できます。',
    );
    return _copyWith(
      newMachine: _stateMachine.._transitionTo(_UserNameFieldStateEnum._saving),
    );
  }

  UserNameFieldState _savingError(String newValue) {
    assert(
      _isSaving,
      '保存中の状態からのみ保存エラー状態に遷移できます。',
    );
    return _copyWith(
      newUserName: newValue,
      newMachine: _stateMachine
        .._transitionTo(_UserNameFieldStateEnum._savingError),
    );
  }

  UserNameFieldState _display() {
    assert(
      _isSaving || isSavingError,
      '保存中または保存エラー状態からのみ表示状態に遷移できます。',
    );
    return _copyWith(
      newMachine: _stateMachine
        .._transitionTo(_UserNameFieldStateEnum._display),
    );
  }

  UserNameFieldState _copyWith({
    String? newUserName,
    _UserNameFieldStateMachine? newMachine,
  }) {
    return UserNameFieldState._(
      newUserName ?? userName,
      newMachine ?? _stateMachine,
    );
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
      _UserNameFieldStateEnum._savingError,
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
    _UserNameFieldStateEnum._savingError: [
      _UserNameFieldStateEnum._saving,
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
  _savingError,
}
