import '../../../domain/models/pair_status.dart';
import '../../../domain/models/user_id.dart';
import '../../../domain/models/user_name.dart';
import '../../../utils/result.dart';

abstract interface class ProfileRepository {
  /// [uid]のペアリング状態を購読する。
  ///
  /// ペア解消を検知した場合は[PairStatus.notPaired]をemitする。
  /// エラー表現はauthStateChanges等と同様に素の[Stream]のままとする
  /// (watchのエラー表現の体系的な決定は、より複雑なwatchが増えるタイミングで行う)。
  Stream<PairStatus> watchPairStatus(UserId uid);

  /// [uid]の公開プロフィールからユーザー名を取得する。失敗時はResult.errorを返す
  Future<Result<UserName>> fetchUserName(UserId uid);

  /// [uid]の公開プロフィールのユーザー名を更新する。失敗時はResult.errorを返す
  Future<Result<void>> updateUserName(UserId uid, UserName userName);
}
