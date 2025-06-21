import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:household_accounts/v2/data/models/privateProfile.dart';

import '../../../../domain/models/vo/user_id.dart';

/// 非公開プロフィールに関するFirestore操作を提供するサービス
class PrivateProfileService {
  final FirebaseFirestore _db;

  const PrivateProfileService(this._db);

  /// ユーザーのプライベートプロファイルを取得する
  Future<Either<Exception, DocumentSnapshot<PrivateProfile>>> fetch(
    UserIdVo userId,
  ) async {
    try {
      final documentSnapshot = await _db
          .doc('/privateProfiles/${userId.value}')
          .withConverter(
            fromFirestore: (snapshot, _) =>
                PrivateProfile.fromJson(snapshot.data()!),
            toFirestore: (data, _) => data.toFirestoreJson(),
          )
          .get();
      return Right(documentSnapshot);
    } on Exception catch (e) {
      return Left(e);
    }
  }
}
