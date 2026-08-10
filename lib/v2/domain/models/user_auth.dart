import 'package:freezed_annotation/freezed_annotation.dart';

import 'vo/user_id.dart';

part 'user_auth.freezed.dart';

@freezed
abstract class UserAuth with _$UserAuth {
  const factory UserAuth({required UserIdVo uid}) = _UserAuth;

  static const UserAuth notSignIn = UserAuth(uid: UserIdVo("not-sign-in"));
}
