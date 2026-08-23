import 'dart:async';

import 'package:household_accounts/data/repositories/profile/profile_repository.dart';
import 'package:household_accounts/domain/models/pair_status.dart';
import 'package:household_accounts/domain/models/user_id.dart';
import 'package:household_accounts/domain/models/user_name.dart';
import 'package:household_accounts/utils/result.dart';

/// Resultを返すinterfaceはmockitoでモック生成できないため手書きFakeを共用する
class FakeProfileRepository implements ProfileRepository {
  /// [watchPairStatus]が返すストリーム。テストから任意のイベントを流せる。
  final StreamController<PairStatus> pairStatusController =
      StreamController<PairStatus>.broadcast();

  /// [fetchUserName]が返す結果。
  Result<UserName> fetchUserNameResult = Result.ok(UserName('テストユーザー'));

  /// 設定すると[fetchUserName]がこのCompleterのFutureを返す。
  /// 完了しないCompleterを渡せば読み込み中の状態を再現できる。
  Completer<Result<UserName>>? fetchUserNameCompleter;

  /// [updateUserName]が返す結果。
  Result<void> updateUserNameResult = const Result.ok(null);

  /// 設定すると[updateUserName]がこのCompleterのFutureを返す。
  /// 完了しないCompleterを渡せば保存中の状態を再現できる。
  Completer<Result<void>>? updateUserNameCompleter;

  int watchPairStatusCallCount = 0;
  int fetchUserNameCallCount = 0;
  int updateUserNameCallCount = 0;

  UserId? lastWatchPairStatusUid;
  UserId? lastFetchUserNameUid;
  UserId? lastUpdateUserNameUid;
  UserName? lastUpdatedUserName;

  @override
  Stream<PairStatus> watchPairStatus(UserId uid) {
    watchPairStatusCallCount++;
    lastWatchPairStatusUid = uid;
    return pairStatusController.stream;
  }

  @override
  Future<Result<UserName>> fetchUserName(UserId uid) {
    fetchUserNameCallCount++;
    lastFetchUserNameUid = uid;

    final completer = fetchUserNameCompleter;
    if (completer != null) {
      return completer.future;
    }
    return Future.value(fetchUserNameResult);
  }

  @override
  Future<Result<void>> updateUserName(UserId uid, UserName userName) {
    updateUserNameCallCount++;
    lastUpdateUserNameUid = uid;
    lastUpdatedUserName = userName;

    final completer = updateUserNameCompleter;
    if (completer != null) {
      return completer.future;
    }
    return Future.value(updateUserNameResult);
  }
}
