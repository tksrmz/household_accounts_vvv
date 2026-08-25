import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/domain/models/user_auth.dart';
import 'package:household_accounts/domain/models/user_id.dart';

void main() {
  group('UserAuth', () {
    test('サインイン済みのとき、signedInUidがuidを返すこと', () {
      final auth = UserAuth.signedIn(UserId('user-1'));

      expect(auth.signedInUid, UserId('user-1'));
    });

    test('サインインしていないとき、signedInUidがStateErrorを送出すること', () {
      const auth = UserAuth.notSignedIn();

      expect(() => auth.signedInUid, throwsStateError);
    });

    test('同じuidのサインイン済み同士は等価であること', () {
      expect(
        UserAuth.signedIn(UserId('user-1')),
        UserAuth.signedIn(UserId('user-1')),
      );
    });

    test('サインイン済みとサインイン未済は等価でないこと', () {
      expect(
        UserAuth.signedIn(UserId('user-1')),
        isNot(const UserAuth.notSignedIn()),
      );
    });
  });
}
