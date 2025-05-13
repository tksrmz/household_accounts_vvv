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
        _userNameFieldState = const _UserNameFieldState('') {
    init = AsyncCommand(this._init);
    save = AsyncCommand0(this._save);
  }

  /// 初期化コマンド
  late final AsyncCommand<UserIdVo> init;

  /// ユーザー名保存コマンド
  late final AsyncCommand0 save;

  /// ユーザー名の状態を管理する
  _UserNameFieldState _userNameFieldState;
  
  bool get isEditing => _userNameFieldState._isEditing;
  String? _userName;
  String? get userName => _userName;
  bool get hasValidationError => _userNameFieldState._isValidationError;
  bool get hasSaveError => _userNameFieldState._isSavingError;

  final PublicProfileRepository _publicProfileRepository;
  UserIdVo? _userId;

  Future<void> _init(UserIdVo userId) async {
    try {
      _userId = userId;
      UserNameVo userName =
          await _publicProfileRepository.fetchUserName(userId);
      _userName = userName.value;
      _userNameFieldState = _UserNameFieldState(userName.value);
    } on Exception catch (ex) {
      developer.log(
        'Failed to fetch user name',
        name: 'SettingsViewModel._init',
        level: Level.WARNING.value,
        error: ex,
        stackTrace: StackTrace.current,
      );
      _userName = null;
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  /// 保存失敗から表示状態へ戻るときに使うユーザー名
  late String _userNameBeforeEditing;

  void startEditing() {
    _userNameBeforeEditing = _userNameFieldState._userName;
    _userNameFieldState = _userNameFieldState._editing();
    notifyListeners();
  }

  void updateUserName(String newName) {
    _userName = newName;
    _userNameFieldState = _userNameFieldState._editing(newName);
    notifyListeners();
  }

  Future<void> _save() async {
    _userNameFieldState = _userNameFieldState._saving();
    notifyListeners();

    try {
      final newUserName = UserNameVo(_userNameFieldState._userName);
      await _publicProfileRepository.updateUserName(_userId!, newUserName);
      _userNameFieldState = _userNameFieldState._display();
    } on Exception catch (ex) {
      developer.log(
        'Failed to save a new user name',
        name: 'SettingsViewModel.save',
        level: Level.WARNING.value,
        error: ex,
        stackTrace: StackTrace.current,
      );
      _userName = _userNameBeforeEditing;
      _userNameFieldState = _userNameFieldState._savingError(
        _userNameBeforeEditing,
      );
    } finally {
      notifyListeners();
    }
  }

  void clearSaveError() {
    _userNameFieldState = _userNameFieldState._display();
    notifyListeners();
  }
}

class _UserNameFieldState {
  const _UserNameFieldState(this._userName)
      : _state = _UserNameFieldStateEnum._display;

  /// [_UserNameFieldState]内からの使用限定
  const _UserNameFieldState._(this._userName, this._state);

  final _UserNameFieldStateEnum _state;
  final String _userName;

  bool get _isDisplay => _state == _UserNameFieldStateEnum._display;
  bool get _isEditing => _state == _UserNameFieldStateEnum._editing;
  bool get _isValidationError =>
      _state == _UserNameFieldStateEnum._validationError;
  bool get _isSaving => _state == _UserNameFieldStateEnum._saving;
  bool get _isSavingError => _state == _UserNameFieldStateEnum._savingError;

  _UserNameFieldState _editing([String? newValue]) {
    assert(
      _isDisplay || _isEditing || _isValidationError,
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

  _UserNameFieldState _validationError(String newValue) {
    assert(
      _isEditing,
      '編集中の状態からのみバリデーションエラー状態に遷移できます。',
    );
    return _copyWith(
      userName: newValue,
      state: _UserNameFieldStateEnum._validationError,
    );
  }

  _UserNameFieldState _saving() {
    assert(
      _isEditing,
      '編集中の状態からのみ保存状態に遷移できます。',
    );
    return _copyWith(state: _UserNameFieldStateEnum._saving);
  }

  _UserNameFieldState _savingError(String newValue) {
    assert(
      _isSaving,
      '保存中の状態からのみ保存エラー状態に遷移できます。',
    );
    return _copyWith(
      userName: newValue,
      state: _UserNameFieldStateEnum._savingError,
    );
  }

  _UserNameFieldState _display() {
    assert(
      _isSaving || _isSavingError,
      '保存中または保存エラー状態からのみ表示状態に遷移できます。',
    );
    return _copyWith(state: _UserNameFieldStateEnum._display);
  }

  _UserNameFieldState _copyWith({
    String? userName,
    _UserNameFieldStateEnum? state,
  }) {
    return _UserNameFieldState._(
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
