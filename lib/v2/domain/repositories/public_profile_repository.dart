import 'package:dartz/dartz.dart';

import '../models/vo/user_id.dart';
import '../models/vo/user_name.dart';

abstract interface class PublicProfileRepository {
  /// 指定されたユーザーIDに紐づくユーザー名を取得する
  Future<Either<Exception, UserNameVo>> fetchUserName(UserIdVo userId);

  /// 指定されたユーザーIDに紐づくユーザー名を更新する
  Future<Either<Exception, Unit>> updateUserName(
      UserIdVo userId, UserNameVo userName);
}
