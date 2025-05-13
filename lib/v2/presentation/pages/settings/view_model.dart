import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import '../../../domain/models/vo/user_id.dart';
import '../../../domain/models/vo/user_name.dart';
import '../../../domain/repositories/public_profile_repository.dart';
import '../../commands/command.dart';

/// 設定画面を表示するためのViewModel
class SettingsViewModel with ChangeNotifier {
  SettingsViewModel({
    required PublicProfileRepository publicProfileRepository,
  })  : _publicProfileRepository = publicProfileRepository,
        userNameFieldState = UserNameFieldState('') {
    init = AsyncCommand(this._init);
    save = AsyncCommand0(this._save);
  }

  /// 初期化コマンド
  late final AsyncCommand<UserIdVo> init;

  /// ユーザー名保存コマンド
  late final AsyncCommand0 save;

  /// ユーザー名の状態を管理する
  UserNameFieldState userNameFieldState;

  bool get isEditing => userNameFieldState._isEditing;
  String? _userName;
  String? get userName => _userName;

  final PublicProfileRepository _publicProfileRepository;
  UserIdVo? _userId;

  Future<void> _init(UserIdVo userId) async {
    try {
      _userId = userId;
      UserNameVo userName =
          await _publicProfileRepository.fetchUserName(userId);
      _userName = userName.value;
      userNameFieldState = UserNameFieldState(userName.value);
    } on Exception catch (ex) {
      developer.log(
        'Failed to fetch user name',
        name: 'SettingsViewModel._init',
        level: Level.WARNING.value,
        error: ex,
        stackTrace: StackTrace.current,
      );
      _userName = null;
      // FIXME rethrowをどうにかしたい
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  /// 保存失敗から表示状態へ戻るときに使うユーザー名
  late String _userNameBeforeEditing;

  void startEditing() {
    _userNameBeforeEditing = userNameFieldState._userName;
    userNameFieldState = userNameFieldState._editing();
    notifyListeners();
  }

  void updateUserName(String newName) {
    _userName = newName;
    userNameFieldState = userNameFieldState._editing(newName);
    notifyListeners();
  }

  Future<void> _save() async {
    userNameFieldState = userNameFieldState._saving();
    notifyListeners();

    try {
      final newUserName = UserNameVo(userNameFieldState._userName);
      await _publicProfileRepository.updateUserName(_userId!, newUserName);
      userNameFieldState = userNameFieldState._display();
    } on Exception catch (ex) {
      developer.log(
        'Failed to save a new user name',
        name: 'SettingsViewModel.save',
        level: Level.WARNING.value,
        error: ex,
        stackTrace: StackTrace.current,
      );
      _userName = _userNameBeforeEditing;
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
  UserNameFieldState(this._userName)
      : _state = _UserNameFieldStateEnum._display;

  /// [UserNameFieldState]内からの使用限定
  UserNameFieldState._(this._userName, this._state);

  final _UserNameFieldStateEnum _state;
  final String _userName;

  bool get _isDisplay => _state == _UserNameFieldStateEnum._display;
  bool get _isEditing => _state == _UserNameFieldStateEnum._editing;
  bool get isValidationError =>
      _state == _UserNameFieldStateEnum._validationError;
  bool get _isSaving => _state == _UserNameFieldStateEnum._saving;
  bool get isSavingError => _state == _UserNameFieldStateEnum._savingError;

  UserNameFieldState _editing([String? newValue]) {
    assert(
      _isDisplay || _isEditing || isValidationError,
      '表示中の状態、編集中、バリデーションエラー状態からのみ編集状態に遷移できます。',
    );

    if (newValue == null || UserNameVo.isValid(newValue)) {
      return _copyWith(
        userName: newValue,
        state: _UserNameFieldStateEnum._editing,
      );
    }

    return _validationError(newValue);
  }

  UserNameFieldState _validationError(String newValue) {
    assert(
      _isEditing,
      '編集中の状態からのみバリデーションエラー状態に遷移できます。',
    );
    return _copyWith(
      userName: newValue,
      state: _UserNameFieldStateEnum._validationError,
    );
  }

  UserNameFieldState _saving() {
    assert(
      _isEditing,
      '編集中の状態からのみ保存状態に遷移できます。',
    );
    return _copyWith(state: _UserNameFieldStateEnum._saving);
  }

  UserNameFieldState _savingError(String newValue) {
    assert(
      _isSaving,
      '保存中の状態からのみ保存エラー状態に遷移できます。',
    );
    return _copyWith(
      userName: newValue,
      state: _UserNameFieldStateEnum._savingError,
    );
  }

  UserNameFieldState _display() {
    assert(
      _isSaving || isSavingError,
      '保存中または保存エラー状態からのみ表示状態に遷移できます。',
    );
    return _copyWith(state: _UserNameFieldStateEnum._display);
  }

  UserNameFieldState _copyWith({
    String? userName,
    _UserNameFieldStateEnum? state,
  }) {
    return UserNameFieldState._(
      userName ?? _userName,
      state ?? _state,
    );
  }

  @override
  String toString() {
    return 'UserNameFieldState{_userName: $_userName, _state: $_state}';
  }
}

enum _UserNameFieldStateEnum {
  _display,
  _editing,
  _validationError,
  _saving,
  _savingError,
}
