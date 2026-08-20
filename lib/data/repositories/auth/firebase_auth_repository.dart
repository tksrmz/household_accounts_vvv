import 'package:firebase_auth/firebase_auth.dart';
import 'package:household_accounts/v2/domain/models/user_auth.dart';

import '../../../utils/result.dart';
import '../../../v2/domain/models/vo/user_id.dart';
import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  @override
  Stream<UserAuth> authStateChanges() =>
      FirebaseAuth.instance.authStateChanges().map(_toUserAuth);

  @override
  UserAuth getCurrentUser() => _toUserAuth(FirebaseAuth.instance.currentUser);

  @override
  Future<Result<void>> signOut() =>
      Result.guard(() => FirebaseAuth.instance.signOut());

  /// Returns [UserAuth] that contains current user info if [user] is not null.
  ///
  /// Returns [UserAuth.notSignIn], otherwise.
  UserAuth _toUserAuth(User? user) {
    return user == null
        ? UserAuth.notSignIn
        : UserAuth(uid: UserIdVo(user.uid));
  }
}
