import 'package:flutter/foundation.dart';
import '../../../domain/models/vo/user_id.dart';
import '../../../domain/models/vo/user_name.dart';
import '../../../domain/repositories/public_profile_repository.dart';
import '../state_managements/initializable_state.dart';

/// 設定画面を表示するためのViewModel
class SettingsViewModel extends ValueNotifier<SettingsState> {
  SettingsViewModel({
    required PublicProfileRepository publicProfileRepository,
  })  : _publicProfileRepository = publicProfileRepository,
        super(SettingsState.uninitialized(UserNameVo.empty));

  final PublicProfileRepository _publicProfileRepository;

  Future<void> init(UserIdVo userId) async {
    if (!value.isUninitialized) {
      return;
    }

    try {
      UserNameVo userName =
          await _publicProfileRepository.fetchUserName(userId);
      value = value.success(userName);
    } on Exception catch (ex) {
      print(ex);
      value = value.fail(UserNameVo.empty);
    }
  }
}

/// 設定画面の状態を表すクラス
typedef SettingsState = InitializableState<UserNameVo>;
