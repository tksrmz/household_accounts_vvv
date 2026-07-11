import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:household_accounts/v2/data/models/property_model.dart';

import '../../../../domain/models/vo/user_id.dart';

/// 個人の資産に関するFirestore操作を提供するサービス
class PersonalPropertyService {
  final FirebaseFirestore _db;

  const PersonalPropertyService(this._db);

  /// [userId]のすべての資産を取得する
  Future<Either<Exception, List<PropertyModel>>> fetchAll(
      UserIdVo userId) async {
    try {
      final querySnapshot = await _db
          .collection('/personalNotes/${userId.value}/properties')
          .get();

      final properties = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // ドキュメントIDを追加
        return PropertyModel.fromJson(data);
      }).toList(growable: false);

      return Right(properties);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  /// [userId]に資産を追加する
  Future<Either<Exception, Unit>> add(
    UserIdVo userId,
    PropertyModel property,
  ) async {
    try {
      await _db
          .collection('/personalNotes/${userId.value}/properties')
          .doc(property.id)
          .set(property.toFirestoreJson());
      return Right(unit);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  /// [userId]の資産を更新する
  Future<Either<Exception, Unit>> update(
    UserIdVo userId,
    PropertyModel property,
  ) async {
    try {
      await _db
          .collection('/personalNotes/${userId.value}/properties')
          .doc(property.id)
          .update(property.toFirestoreJson());
      return Right(unit);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  /// [userId]の資産を削除する
  Future<Either<Exception, Unit>> delete(
    UserIdVo userId,
    String propertyId,
  ) async {
    try {
      await _db
          .collection('/personalNotes/${userId.value}/properties')
          .doc(propertyId)
          .delete();
      return Right(unit);
    } on Exception catch (e) {
      return Left(e);
    }
  }
}
