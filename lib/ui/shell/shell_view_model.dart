import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../data/repositories/auth/auth_repository.dart';
import '../../data/repositories/profile/profile_repository.dart';
import '../../domain/models/pair_status.dart';
import '../../domain/models/user_id.dart';
import '../../presentation/util/model/user_info.dart';
import '../../utils/command.dart';
// utils/result.dartが独自の`Error<T>`(Resultの失敗variant)を公開しており、
// dart:coreの`Error`(Error.throwWithStackTrace)と名前が衝突するため、
// このファイルでは使わないResult側のErrorを隠してdart:core側を残す。
import '../../utils/result.dart' hide Error;
import '../../v2/presentation/pages/state_managements/selected_note_state.dart';

/// ペア検知の状態を表すUI向けの状態表現。
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
    required ProfileRepository profileRepository,
  }) : _authRepository = authRepository,
       _selectedNoteState = selectedNoteState {
    logout = Command0(_logout);
    // シェルは認証済みでのみマウントされる(routerのredirectが保証)
    _uid = authRepository.getCurrentUser().signedInUid;
    // ドロワー表示をノート切替へ追従させる
    _selectedNoteState.addListener(notifyListeners);
    _subscription = profileRepository
        .watchPairStatus(_uid)
        .listen(_onPairStatus, onError: _onPairError);
  }

  final AuthRepository _authRepository;
  final SelectedNoteState _selectedNoteState;

  late final UserId _uid;
  late final StreamSubscription<PairStatus> _subscription;

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

  void _onPairStatus(PairStatus status) {
    final pairId = switch (status) {
      Paired(:final pairId) => pairId,
      NotPaired() => null,
    };
    // ペア解消時に選択中ノートがsharedのまま残ると共有ノートを解決できなく
    // なるため、personalへの強制リセットはSelectedNoteState自身に委ねる
    // (pairIdの消失とリセットを1回の通知で原子的に行う責務のため)
    _selectedNoteState.updatePairId(pairId);
    _pairState = ShellPairData(pairId?.value);
    _userInfo = UserInfo(uid: _uid.value, pairId: pairId?.value);
    notifyListeners();
  }

  /// [Result.guard]と同じ区分(Exception=想定内の失敗/Error=プログラミングバグ)を
  /// Stream購読でも貫く。Errorを状態化せず再送出するのは、実装バグを
  /// エラー表示に隠して気づけなくする事態を避けるため。
  void _onPairError(Object error, StackTrace stackTrace) {
    if (error is! Exception) {
      Error.throwWithStackTrace(error, stackTrace);
    }
    // エラーUIは詳細を表示しないため、原因調査の手がかりをログへ残す
    developer.log(
      'ペア検知の購読が失敗しました',
      name: 'ShellViewModel',
      level: Level.WARNING.value,
      error: error,
      stackTrace: stackTrace,
    );
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
