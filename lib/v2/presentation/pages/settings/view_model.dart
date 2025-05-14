import 'package:flutter/foundation.dart';

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
  late final AsyncCommand<UserNameVo> save;

  /// ユーザー名の状態を管理する
  late final UserNameFieldState userNameFieldState;

  /// 編集前のユーザー名
  late UserNameVo _userNameBeforeEdit;
  String get userName => _userNameBeforeEdit.value;

  final PublicProfileRepository _publicProfileRepository;
  final AuthRepository _authRepository;

  Future<void> _init(UserIdVo userId) async {
    _userNameBeforeEdit = await _publicProfileRepository.fetchUserName(userId);
    save = AsyncCommand((newUserName) => this._save(userId, newUserName));
    userNameFieldState = UserNameFieldState(save);
  }

  Future<void> _save(UserIdVo userId, UserNameVo newUserName) async {
    userNameFieldState._saving();

    await _publicProfileRepository.updateUserName(userId, newUserName);
    userNameFieldState._display();
    _userNameBeforeEdit = newUserName;
  }
}

/// ユーザー名表示/編集の状態
class UserNameFieldState with ChangeNotifier {
  UserNameFieldState(this._save) : _stateMachine = _UserNameFieldStateMachine();

  /// 状態管理
  final _UserNameFieldStateMachine _stateMachine;

  /// ユーザー名保存コマンド
  final AsyncCommand<UserNameVo> _save;

  bool get _isDisplay =>
      _stateMachine._current == _UserNameFieldStateEnum._display;
  bool get isValidationError =>
      _stateMachine._current == _UserNameFieldStateEnum._validationError;

  void startEditing() {
    assert(_isDisplay, '編集を開始できるのは表示状態のときのみ');
    _stateMachine._transitionTo(_UserNameFieldStateEnum._editing);
    notifyListeners();
  }

  void updateUserName(String newName) {
    assert(
      _stateMachine._current == _UserNameFieldStateEnum._editing ||
          isValidationError,
      '更新できるのは編集中かバリデーションエラーのときのみ',
    );

    final next;
    if (UserNameVo.isValid(newName)) {
      next = _UserNameFieldStateEnum._editing;
    } else {
      next = _UserNameFieldStateEnum._validationError;
    }

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
