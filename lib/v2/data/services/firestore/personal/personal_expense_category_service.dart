import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:household_accounts/v2/data/models/expense_category_model.dart';

import '../../../../domain/models/vo/user_id.dart';

/// 個人の支出カテゴリに関するFirestore操作を提供するサービス
class PersonalExpenseCategoryService {
  final FirebaseFirestore _db;

  const PersonalExpenseCategoryService(this._db);

  /// [userId]のすべての支出カテゴリを取得する
  Future<Either<Exception, List<ExpenseCategoryModel>>> fetchAll(
      UserIdVo userId) async {
    try {
      final querySnapshot = await _db
          .collection('/personalNotes/${userId.value}/expenseCategories')
          .get();

      final categories = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // ドキュメントIDを追加
        return ExpenseCategoryModel.fromJson(data);
      }).toList(growable: false);

      return Right(categories);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  /// [userId]に支出カテゴリを追加する
  Future<Either<Exception, Unit>> add(
    UserIdVo userId,
    ExpenseCategoryModel category,
  ) async {
    try {
      await _db
          .collection('/personalNotes/${userId.value}/expenseCategories')
          .doc(category.id)
          .set(category.toFirestoreJson());
      return Right(unit);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  /// [userId]の支出カテゴリを更新する
  Future<Either<Exception, Unit>> update(
    UserIdVo userId,
    ExpenseCategoryModel category,
  ) async {
    try {
      await _db
          .collection('/personalNotes/${userId.value}/expenseCategories')
          .doc(category.id)
          .update(category.toFirestoreJson());
      return Right(unit);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  /// [userId]の支出カテゴリを削除する
  Future<Either<Exception, Unit>> delete(
    UserIdVo userId,
    String categoryId,
  ) async {
    try {
      await _db
          .collection('/personalNotes/${userId.value}/expenseCategories')
          .doc(categoryId)
          .delete();
      return Right(unit);
    } on Exception catch (e) {
      return Left(e);
    }
  }
}
