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
    implements Repository<ExpenseCategory> {
  final CollectionReferenceBuilder<ExpenseCategoryModel>
      _collectionReferenceBuilder;
  final _firebase = FirebaseRepositoryBasicOperation<ExpenseCategoryModel>();

  _FirebaseExpenseCategoryRepository._(this._collectionReferenceBuilder);

  @override
  Future<ExceptionOr<Unit>> deleteById({
    required String repoId,
    required String id,
  }) =>
      _firebase.delete(_collectionReferenceBuilder(repoId).doc(id));

  @override
  Future<ExceptionOr<Unit>> register({
    required String repoId,
    required ExpenseCategory value,
  }) =>
      _firebase.register(
        _collectionReferenceBuilder(repoId).doc(value.id),
        ExpenseCategoryModel.fromExpenseCategory(value),
      );

  @override
  Future<ExceptionOr<List<ExpenseCategory>>> retrieveAll({
    required String repoId,
  }) async {
    final exceptionOrModelList = await _firebase.retrieveAll(
      _collectionReferenceBuilder(repoId),
      'name',
    );
    final toCategories = (List<ExpenseCategoryModel> list) =>
        list.map<ExpenseCategory>((item) => item.toEntity()).toList();
    return exceptionOrModelList.map(toCategories);
  }

  @override
  Future<ExceptionOr<ExpenseCategory>> retrieveById({
    required String repoId,
    required String id,
  }) async {
    final docRef = _collectionReferenceBuilder(repoId).doc(id);
    final exceptionOrModel = await _firebase.retrieve(docRef);
    final toEntity = (ExpenseCategoryModel model) => model.toEntity();
    return exceptionOrModel.map(toEntity);
  }

  @override
  Future<ExceptionOr<Unit>> update({
    required String repoId,
    required ExpenseCategory newValue,
  }) =>
      _firebase.update(
        _collectionReferenceBuilder(repoId).doc(newValue.id),
        ExpenseCategoryModel.fromExpenseCategory(newValue),
      );
}
