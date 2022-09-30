import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../entity/category_entity.dart';
import '../../feature/repository/category_repository.dart';
import '../../util/constant/firebase_constant.dart';
import '../../util/type/exception_or.dart';
import 'category_model.dart';
import 'firebase_repository.dart';
import 'util/type/collection_reference_builder.dart';

class FirebasePersonalExpenseCategoryRepository
    extends _FirebaseExpenseCategoryRepository {
  FirebasePersonalExpenseCategoryRepository()
      : super._(
          (String uid) => FirebaseFirestore.instance
              .collection(
                  '/$FIREBASE_COLLECTION_PERSONAL_NOTES/$uid/$FIREBASE_COLLECTION_EXPENSE_CATEGORIES')
              .withConverter<ExpenseCategoryModel>(
                fromFirestore: _fromFirestore,
                toFirestore: _toFirestore,
              ),
        );
}

class FirebaseSharedExpenseCategoryRepository
    extends _FirebaseExpenseCategoryRepository {
  FirebaseSharedExpenseCategoryRepository()
      : super._(
          (String pairId) => FirebaseFirestore.instance
              .collection(
                  '/$FIREBASE_COLLECTION_SHARED_NOTES/$pairId/$FIREBASE_COLLECTION_EXPENSE_CATEGORIES')
              .withConverter<ExpenseCategoryModel>(
                fromFirestore: _fromFirestore,
                toFirestore: _toFirestore,
              ),
        );
}

final _fromFirestore = (
  DocumentSnapshot<Map<String, dynamic>> snapshot,
  SnapshotOptions? _,
) =>
    ExpenseCategoryModel.fromIdAndJson(
      snapshot.id,
      snapshot.data()!,
    );

final _toFirestore = (
  ExpenseCategoryModel value,
  SetOptions? _,
) =>
    value.toJson();

class _FirebaseExpenseCategoryRepository implements ExpenseCategoryRepository2 {
  final CollectionReferenceBuilder<ExpenseCategoryModel>
      _collectionReferenceBuilder;
  final _operation =
      FirebaseRepositoryBasicOperation<ExpenseCategory, ExpenseCategoryModel>();

  _FirebaseExpenseCategoryRepository._(this._collectionReferenceBuilder);

  @override
  Future<ExceptionOr<Unit>> deleteById({
    required String repoId,
    required String id,
  }) =>
      _operation.deleteById(
        ref: _collectionReferenceBuilder(repoId),
        id: id,
      );

  @override
  Future<ExceptionOr<Unit>> register({
    required String repoId,
    required ExpenseCategory value,
  }) =>
      _operation.register(
        ref: _collectionReferenceBuilder(repoId),
        entity: value,
        entityToModel: ExpenseCategoryModel.fromExpenseCategory,
      );

  @override
  Future<ExceptionOr<List<ExpenseCategory>>> retrieveAll({
    required String repoId,
  }) =>
      _operation.retrieveAll(
        ref: _collectionReferenceBuilder(repoId),
        sortKey: 'name',
      );

  @override
  Future<ExceptionOr<ExpenseCategory>> retrieveById({
    required String repoId,
    required String id,
  }) =>
      _operation.retrieveById(
        ref: _collectionReferenceBuilder(repoId),
        id: id,
      );

  @override
  Future<ExceptionOr<Unit>> update({
    required String repoId,
    required ExpenseCategory newValue,
  }) {
    final toJson = (ExpenseCategory expenseCategory) =>
        ExpenseCategoryModel.fromExpenseCategory(expenseCategory).toJson();

    return _operation.update(
      ref: _collectionReferenceBuilder(repoId),
      newValue: newValue,
      entityToJson: toJson,
    );
  }
}
