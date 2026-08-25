import '../../../domain/models/user_auth.dart';
import '../../../utils/result.dart';

abstract interface class AuthRepository {
  /// Wrapper of FirebaseAuth.instance.authStateChange but returns [UserAuth].
  ///
  /// Returns [UserAuth.notSignedIn] when the user is not signed in.
  Stream<UserAuth> authStateChanges();

  /// Returns current sign-in user info.
  ///
  /// Returns [UserAuth.notSignedIn] when the user is not signed in.
  UserAuth getCurrentUser();

  /// サインアウトする。失敗時はResult.errorを返す
  Future<Result<void>> signOut();
}
