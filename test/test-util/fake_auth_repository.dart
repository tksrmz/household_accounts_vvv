import 'package:household_accounts/data/repositories/auth/auth_repository.dart';
import 'package:household_accounts/domain/models/user_auth.dart';
import 'package:household_accounts/utils/result.dart';

/// Resultを返すinterfaceはmockitoでモック生成できないため手書きFakeを共用する
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({UserAuth? currentUser})
    : currentUser = currentUser ?? UserAuth.notSignIn;

  UserAuth currentUser;
  Stream<UserAuth> authStateChangesStream = const Stream.empty();
  Result<void> signOutResult = const Result.ok(null);
  int signOutCallCount = 0;

  @override
  Stream<UserAuth> authStateChanges() => authStateChangesStream;

  @override
  UserAuth getCurrentUser() => currentUser;

  @override
  Future<Result<void>> signOut() async {
    signOutCallCount++;
    return signOutResult;
  }
}
