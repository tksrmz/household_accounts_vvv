import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../domain/models/vo/user_id.dart';
import '../../../../domain/models/vo/user_name.dart';

/// 公開プロフィールに関するFirestore操作を提供するサービス
class PublicProfileService {
  final FirebaseFirestore _db;

  const PublicProfileService(this._db);

  /// [userId]の公開プロフィールを取得する
  Future<Either<Exception, Map<String, dynamic>>> fetchPublicProfileOf(
      UserIdVo userId) async {
    try {
      final documentReference = _db.doc('/publicProfiles/${userId.value}');
      final documentSnapshot = await documentReference.get();
      return Right(documentSnapshot.data()!);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  /// [userId]のユーザー名を更新する
  Future<Either<Exception, Unit>> updatePublicProfileNameOf(
    UserIdVo userId,
    UserNameVo userName,
  ) async {
    try {
      final documentReference = _db.doc('/publicProfiles/${userId.value}');
      await documentReference.update({
        'name': userName.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return Right(unit);
    } on Exception catch (e) {
      return Left(e);
    }
  }
}