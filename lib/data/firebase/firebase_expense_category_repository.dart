import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:household_accounts/data/firebase/util/document_snapshot.dart';

import '../../entity/category_entity.dart';
import '../../feature/repository/category_repository.dart';
import '../../util/type/exception_or.dart';
import '../../util/type/json.dart';
import '../../util/type/repository.dart';
import 'category_model.dart';
import 'firebase_repository.dart';
import 'util/path_builder.dart';
import 'util/type/collection_reference_builder.dart';

class FirebasePersonalExpenseCategoryRepository
    extends _FirebaseExpenseCategoryRepository
    implements PersonalExpenseCategoryRepository {
  FirebasePersonalExpenseCategoryRepository()
      : super._(
          (String uid) => FirebaseFirestore.instance
              .collection(getPersonalExpenseCategoryCollectionPath(uid))
              .withConverter<ExpenseCategoryModel>(
                fromFirestore: _fromFirestore,
                toFirestore: _toFirestore,
              ),
        );
}

class FirebaseSharedExpenseCategoryRepository
    extends _FirebaseExpenseCategoryRepository
    implements SharedExpenseCategoryRepository {
  FirebaseSharedExpenseCategoryRepository()
      : super._(
          (String pairId) => FirebaseFirestore.instance
              .collection(getSharedExpenseCategoryCollectionPath(pairId))
              .withConverter<ExpenseCategoryModel>(
                fromFirestore: _fromFirestore,
                toFirestore: _toFirestore,
              ),
        );
}

final _fromFirestore = (
  DocumentSnapshot<Json> snapshot,
  SnapshotOptions? _,
) =>
    ExpenseCategoryModel.fromJson(snapshot.toJsonWithId());

final _toFirestore = (
  ExpenseCategoryModel value,
  SetOptions? _,
) =>
    value.toJson();

class _FirebaseExpenseCategoryRepository
    implements Repository2<ExpenseCategory> {
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
