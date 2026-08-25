import 'package:firebase_auth/firebase_auth.dart';
import 'package:household_accounts/domain/models/user_auth.dart';

import '../../../domain/models/user_id.dart';
import '../../../utils/result.dart';
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
  /// Returns [UserAuth.notSignedIn], otherwise.
  UserAuth _toUserAuth(User? user) {
    return user == null
        ? const UserAuth.notSignedIn()
        : UserAuth.signedIn(UserId(user.uid));
  }
}
