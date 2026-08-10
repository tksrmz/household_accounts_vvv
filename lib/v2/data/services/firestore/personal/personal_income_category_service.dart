import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:household_accounts/v2/data/models/income_category_model.dart';

import '../../../../domain/models/vo/user_id.dart';

/// 個人の収入カテゴリに関するFirestore操作を提供するサービス
class PersonalIncomeCategoryService {
  final FirebaseFirestore _db;

  const PersonalIncomeCategoryService(this._db);

  /// [userId]のすべての収入カテゴリを取得する
  Future<Either<Exception, List<IncomeCategoryModel>>> fetchAll(
    UserIdVo userId,
  ) async {
    try {
      final querySnapshot = await _db
          .collection('/personalNotes/${userId.value}/incomeCategories')
          .get();

      final categories = querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // ドキュメントIDを追加
            return IncomeCategoryModel.fromJson(data);
          })
          .toList(growable: false);

      return Right(categories);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  /// [userId]に収入カテゴリを追加する
  Future<Either<Exception, Unit>> add(
    UserIdVo userId,
    IncomeCategoryModel category,
  ) async {
    try {
      await _db
          .collection('/personalNotes/${userId.value}/incomeCategories')
          .doc(category.id)
          .set(category.toFirestoreJson());
      return Right(unit);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  /// [userId]の収入カテゴリを更新する
  Future<Either<Exception, Unit>> update(
    UserIdVo userId,
    IncomeCategoryModel category,
  ) async {
    try {
      await _db
          .collection('/personalNotes/${userId.value}/incomeCategories')
          .doc(category.id)
          .update(category.toFirestoreJson());
      return Right(unit);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  /// [userId]の収入カテゴリを削除する
  Future<Either<Exception, Unit>> delete(
    UserIdVo userId,
    String categoryId,
  ) async {
    try {
      await _db
          .collection('/personalNotes/${userId.value}/incomeCategories')
          .doc(categoryId)
          .delete();
      return Right(unit);
    } on Exception catch (e) {
      return Left(e);
    }
  }
}
