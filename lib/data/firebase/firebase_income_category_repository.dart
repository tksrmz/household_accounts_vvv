import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../entity/category_entity.dart';
import '../../feature/repository/category_repository.dart';
import '../../util/type/exception_or.dart';
import '../../util/type/repository.dart';
import 'category_model.dart';
import 'firebase_repository.dart';
import 'util/path_builder.dart';
import 'util/type/collection_reference_builder.dart';

class FirebasePersonalIncomeCategoryRepository
    extends _FirebaseIncomeCategoryRepository
    implements PersonalIncomeCategoryRepository {
  FirebasePersonalIncomeCategoryRepository()
      : super._(
          (String uid) => FirebaseFirestore.instance
              .collection(getPersonalIncomeCategoryCollectionPath(uid))
              .withConverter<IncomeCategoryModel>(
                fromFirestore: _fromFirestore,
                toFirestore: _toFirestore,
              ),
        );
}

class FirebaseSharedIncomeCategoryRepository
    extends _FirebaseIncomeCategoryRepository
    implements SharedIncomeCategoryRepository {
  FirebaseSharedIncomeCategoryRepository()
      : super._(
          (String pairId) => FirebaseFirestore.instance
              .collection(getSharedIncomeCategoryCollectionPath(pairId))
              .withConverter<IncomeCategoryModel>(
                fromFirestore: _fromFirestore,
                toFirestore: _toFirestore,
              ),
        );
}

final _fromFirestore = (
  DocumentSnapshot<Map<String, dynamic>> snapshot,
  SnapshotOptions? _,
) =>
    IncomeCategoryModel.fromIdAndJson(
      snapshot.id,
      snapshot.data()!,
    );

final _toFirestore = (
  IncomeCategoryModel value,
  SetOptions? _,
) =>
    value.toJson();

class _FirebaseIncomeCategoryRepository implements Repository2<IncomeCategory> {
  final CollectionReferenceBuilder<IncomeCategoryModel>
      _collectionReferenceBuilder;
  final _operation =
      FirebaseRepositoryBasicOperation<IncomeCategory, IncomeCategoryModel>();

  _FirebaseIncomeCategoryRepository._(this._collectionReferenceBuilder);

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
    required IncomeCategory value,
  }) =>
      _operation.register(
        ref: _collectionReferenceBuilder(repoId),
        entity: value,
        entityToModel: IncomeCategoryModel.fromIncomeCategory,
      );

  @override
  Future<ExceptionOr<List<IncomeCategory>>> retrieveAll({
    required String repoId,
  }) =>
      _operation.retrieveAll(
        ref: _collectionReferenceBuilder(repoId),
        sortKey: 'name',
      );

  @override
  Future<ExceptionOr<IncomeCategory>> retrieveById({
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
    required IncomeCategory newValue,
  }) {
    final toJson = (IncomeCategory incomeCategory) =>
        IncomeCategoryModel.fromIncomeCategory(incomeCategory).toJson();

    return _operation.update(
      ref: _collectionReferenceBuilder(repoId),
      newValue: newValue,
      entityToJson: toJson,
    );
  }
}
