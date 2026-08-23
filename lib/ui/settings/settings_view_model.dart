import 'package:flutter/foundation.dart';

import '../../data/repositories/auth/auth_repository.dart';
import '../../data/repositories/profile/profile_repository.dart';
import '../../domain/models/user_id.dart';
import '../../domain/models/user_name.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// 設定画面の状態を持つViewModel。
class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({
    required ProfileRepository profileRepository,
    required AuthRepository authRepository,
  }) : _profileRepository = profileRepository,
       // 設定画面は認証済みでのみ到達する(routerのredirectが保証)
       _userId = UserId(authRepository.getCurrentUser().uid.value) {
    saveUserName = Command1(_save);
    // 画面を開いた時点で読み込みを始める(Viewからの明示的な初期化呼び出しは不要)
    load = Command0(_load)..execute();
  }

  final ProfileRepository _profileRepository;
  final UserId _userId;

  /// ユーザー名の読み込みコマンド。生成と同時に実行される。
  late final Command0<void> load;

  /// 検証済みのユーザー名を保存するコマンド。
  ///
  /// 引数を検証済みの[UserName]に限ることで、文字数の検証漏れを型で防ぐ。
  /// 検証はUI層の関心事として[save]が担い、このコマンドの失敗は
  /// データ層由来の失敗だけを表す。
  late final Command1<void, UserName> saveUserName;

  // 表示名をload結果ではなくVMのフィールドで保持する理由:
  // 保存が成功すると表示名は読み込み時の値から変わるため、loadコマンドの結果は
  // 表示名の源泉になりえない。表示名の源泉をこのフィールド1つに絞ることで、
  // 読み込み由来と保存由来の値が二重管理になるのを防ぐ。
  UserName? _userName;

  /// 表示中のユーザー名。読み込み完了前は空文字。
  String get userName => _userName?.value ?? '';

  bool _isEditing = false;

  /// ユーザー名を編集中かどうか。
  bool get isEditing => _isEditing;

  bool _hasValidationError = false;

  /// 入力されたユーザー名が検証エラーかどうか。
  ///
  /// エラーの文言はUIの関心事なのでここでは持たず、表示するWidgetが決める。
  bool get hasValidationError => _hasValidationError;

  /// ユーザー名を保存できるかどうか。
  bool get canSave => !saveUserName.running;

  /// ユーザー名の編集を開始する。
  void startEditing() {
    _isEditing = true;
    notifyListeners();
  }

  /// 入力された[input]を検証し、妥当なら保存する。
  ///
  /// 検証は[UserName]の生成そのもので行う(生成できた＝妥当)。失敗した場合は
  /// コマンドを実行せず、編集状態を保ったまま検証エラーの状態だけを更新する
  /// (入力し直せるようにするため)。
  Future<void> save(String input) async {
    final UserName userName;
    try {
      userName = UserName(input);
    } on FormatException {
      _hasValidationError = true;
      notifyListeners();
      return;
    }

    _hasValidationError = false;
    await saveUserName.execute(userName);
  }

  Future<Result<void>> _load() async {
    final result = await _profileRepository.fetchUserName(_userId);
    switch (result) {
      case Ok(:final value):
        _userName = value;
        return const Result.ok(null);
      case Error(:final error):
        return Result.error(error);
    }
  }

  Future<Result<void>> _save(UserName newUserName) async {
    final result = await _profileRepository.updateUserName(
      _userId,
      newUserName,
    );
    // 保存に失敗したときは編集前の値を保つ(表示を巻き戻せるようにするため)
    if (result is Ok<void>) {
      _userName = newUserName;
    }
    // 成功・失敗どちらでも編集は終了する
    _isEditing = false;
    notifyListeners();
    return result;
  }
}
