import 'package:flutter/foundation.dart';

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
        _authRepository = authRepository {
    init = AsyncCommand(this._init)..call(_authRepository.getCurrentUser().uid);
  }

  /// 初期化コマンド
  late final AsyncCommand<UserIdVo> init;

  /// ユーザー名保存コマンド
  late final AsyncCommand<String> save;

  /// 編集前のユーザー名
  late UserNameVo _userNameBeforeEdit;
  String get userName => _userNameBeforeEdit.value;

  /// 編集モードかどうか
  bool _isEditing = false;
  bool get isEditing => _isEditing;

  /// ユーザー名のバリデーションエラー判定フラグ
  bool _hasValidationError = false;
  bool get hasValidationError => _hasValidationError;

  /// ユーザー名をセーブできるかどうか
  bool get canSave => save.canExecute;

  final PublicProfileRepository _publicProfileRepository;
  final AuthRepository _authRepository;

  Future<void> _init(UserIdVo userId) async {
    _userNameBeforeEdit = await _publicProfileRepository.fetchUserName(userId);
    save = AsyncCommand((newUserName) => this._save(userId, newUserName));
  }

  void startEditing() {
    _isEditing = true;
    notifyListeners();
  }

  Future<void> _save(UserIdVo userId, String newUserName) async {
    if (UserNameVo.isNotValid(newUserName)) {
      _hasValidationError = true;
      notifyListeners();
      return;
    }
    _hasValidationError = false;
    final vo = UserNameVo(newUserName);

    try {
      await _publicProfileRepository.updateUserName(userId, vo);
      _userNameBeforeEdit = vo;
    } catch (e) {
      // 保存に失敗した場合は編集前の状態に戻す
      rethrow;
    } finally {
      _isEditing = false;
      notifyListeners();
    }
  }
}
