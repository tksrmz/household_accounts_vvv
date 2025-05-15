import '../models/user_auth.dart';

abstract interface class AuthRepository {
  /// Wrapper of FirebaseAuth.instance.authStateChange but returns [UserAuth].
  ///
  /// Returns [UserAuth.notSignIn] when the user is not signed in.
  Stream<UserAuth> authStateChanges();

  /// Returns current sign-in user info.
  ///
  /// Returns [UserAuth.notSignIn] when the user is not signed in.
  UserAuth getCurrentUser();
}
