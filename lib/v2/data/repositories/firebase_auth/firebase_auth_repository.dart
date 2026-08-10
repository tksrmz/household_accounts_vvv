import 'package:firebase_auth/firebase_auth.dart';
import 'package:household_accounts/v2/domain/models/user_auth.dart';

import '../../../domain/models/vo/user_id.dart';
import '../../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  @override
  Stream<UserAuth> authStateChanges() =>
      FirebaseAuth.instance.authStateChanges().map(_toUserAuth);

  @override
  UserAuth getCurrentUser() => _toUserAuth(FirebaseAuth.instance.currentUser);

  /// Returns [UserAuth] that contains current user info if [user] is not null.
  ///
  /// Returns [UserAuth.notSignIn], otherwise.
  UserAuth _toUserAuth(User? user) {
    return user == null
        ? UserAuth.notSignIn
        : UserAuth(uid: UserIdVo(user.uid));
  }
}
