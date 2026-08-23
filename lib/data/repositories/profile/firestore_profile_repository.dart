import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../domain/models/pair_id.dart';
import '../../../domain/models/pair_status.dart';
import '../../../domain/models/user_id.dart';
import '../../../domain/models/user_name.dart';
import '../../../utils/result.dart';
import 'profile_repository.dart';

class FirestoreProfileRepository implements ProfileRepository {
  const FirestoreProfileRepository(this._db);

  final FirebaseFirestore _db;

  @override
  Stream<PairStatus> watchPairStatus(UserId uid) {
    return _db
        .doc('privateProfiles/${uid.value}')
        .snapshots()
        // doc未作成(サインアップ直後)はemitせずローディング維持
        .where((snapshot) => snapshot.exists)
        .map((snapshot) {
          final sharedNote =
              snapshot.data()?['sharedNote'] as Map<String, dynamic>?;
          if (sharedNote == null) {
            return const PairStatus.notPaired();
          }
          final ref = sharedNote['ref'] as DocumentReference;
          return PairStatus.paired(PairId(ref.id));
        });
  }

  @override
  Future<Result<UserName>> fetchUserName(UserId uid) =>
      Result.guard(() => _fetchUserName(uid));

  /// [Result.guard]は`on Exception`のみ捕捉しErrorは伝播させる(fail fast)設計のため、
  /// ドキュメント不在やフィールド欠如をTypeError等のErrorに委ねず、
  /// 明示的にExceptionとしてthrowする。
  Future<UserName> _fetchUserName(UserId uid) async {
    final snapshot = await _db.doc('publicProfiles/${uid.value}').get();
    final name = snapshot.data()?['name'];
    if (name is! String) {
      throw Exception('公開プロフィールが見つかりません: uid=${uid.value}');
    }
    return UserName(name);
  }

  @override
  Future<Result<void>> updateUserName(UserId uid, UserName userName) =>
      Result.guard(
        () => _db.doc('publicProfiles/${uid.value}').update({
          'name': userName.value,
          'updatedAt': FieldValue.serverTimestamp(),
        }),
      );
}
