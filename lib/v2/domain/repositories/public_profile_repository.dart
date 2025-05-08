import '../models/vo/user_id.dart';
import '../models/vo/user_name.dart';

abstract interface class PublicProfileRepository {
  /// 指定されたユーザーIDに紐づくユーザー名を取得する
  Future<UserNameVo> fetchUserName(UserIdVo userId);

  /// 指定されたユーザーIDに紐づくユーザー名を更新する
  Future<void> updateUserName(UserIdVo userId, UserNameVo userName);
}
