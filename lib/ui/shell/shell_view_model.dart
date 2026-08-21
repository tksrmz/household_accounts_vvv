import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/repositories/auth/auth_repository.dart';
import '../../presentation/util/model/user_info.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';
import '../../v2/presentation/pages/state_managements/selected_note_state.dart';

/// ペア検知の状態。PR2でProfileRepositoryのwatchへ置換されるまでの一時的なUI状態表現。
sealed class ShellPairState {
  const ShellPairState();
}

/// ペア情報をまだ取得できていない状態。
final class ShellPairLoading extends ShellPairState {
  const ShellPairLoading();
}

/// ペア情報の購読でエラーが発生した状態。
final class ShellPairError extends ShellPairState {
  const ShellPairError(this.error);

  /// 発生したエラー。
  final Object error;
}

/// ペア情報を取得できた状態。[pairId] が `null` ならペア未設定。
final class ShellPairData extends ShellPairState {
  const ShellPairData(this.pairId);

  /// ペアの共有ノートID。ペアがいない場合は `null`。
  final String? pairId;
}

/// アプリのシェル(タブ + ドロワー)の状態を持つViewModel。
class ShellViewModel extends ChangeNotifier {
  ShellViewModel({
    required AuthRepository authRepository,
    required SelectedNoteState selectedNoteState,
    required Stream<String?> Function(String uid) watchPairId,
  }) : _authRepository = authRepository,
       _selectedNoteState = selectedNoteState {
    logout = Command0(_logout);
    // シェルは認証済みでのみマウントされる(routerのredirectが保証)
    _uid = authRepository.getCurrentUser().uid.value;
    // ドロワー表示をノート切替へ追従させる
    _selectedNoteState.addListener(notifyListeners);
    _subscription = watchPairId(_uid).listen(_onPairId, onError: _onPairError);
  }

  final AuthRepository _authRepository;
  final SelectedNoteState _selectedNoteState;

  late final String _uid;
  late final StreamSubscription<String?> _subscription;

  ShellPairState _pairState = const ShellPairLoading();

  /// ペア検知の状態。
  ShellPairState get pairState => _pairState;

  UserInfo? _userInfo;

  /// ペア検知が完了していれば、そのユーザー情報。未完了なら `null`。
  UserInfo? get userInfo => _userInfo;

  /// ノート切替が可能かどうか(= ペアが存在するかどうか)。
  bool get canSwitchNote => _userInfo?.hasPair ?? false;

  /// 現在選択されているノート。
  SelectedNote get selectedNote => _selectedNoteState.value;

  /// ログアウトを実行するコマンド。
  late final Command0<void> logout;

  /// 表示するノートを切り替える。
  void switchNote(SelectedNote note) => _selectedNoteState.select(note);

  void _onPairId(String? pairId) {
    _pairState = ShellPairData(pairId);
    _userInfo = UserInfo(uid: _uid, pairId: pairId);
    notifyListeners();
  }

  void _onPairError(Object error, StackTrace stackTrace) {
    _pairState = ShellPairError(error);
    notifyListeners();
  }

  // 旧実装の `sl.reset()` は移植しない。get_it登録は全てステートレスな
  // registerFactoryでresetに実益がなく、reset後の再登録経路が無いため
  // 再ログイン時にクラッシュする一因だった(2026-08-19の移行判断で廃止)。
  Future<Result<void>> _logout() => _authRepository.signOut();

  @override
  void dispose() {
    _subscription.cancel();
    _selectedNoteState.removeListener(notifyListeners);
    super.dispose();
  }
}
