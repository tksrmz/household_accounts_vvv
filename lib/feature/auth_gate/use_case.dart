import 'package:firebase_auth/firebase_auth.dart' hide User;

import 'user.dart';

class AuthUseCase {
  /// Wrapper for [FirebaseAuth.authStateChanges]
  Stream<User?> authStateChanges() {
    return FirebaseAuth.instance.authStateChanges().map((user) {
      if (user == null) {
        return null;
      }
      return User(uid: user.uid);
    });
  }
}