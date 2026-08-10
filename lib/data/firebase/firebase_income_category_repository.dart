import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../entity/category.dart';
import '../../feature/repository/category_repository.dart';
import '../../util/type/exception_or.dart';
import '../../util/type/json.dart';
import '../../util/type/repository.dart';
import 'category_model.dart';
import 'firebase_repository.dart';
import 'util/document_snapshot.dart';
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

IncomeCategoryModel _fromFirestore(
  DocumentSnapshot<Json> snapshot,
  SnapshotOptions? _,
) => IncomeCategoryModel.fromJson(snapshot.toJsonWithId());

Json _toFirestore(IncomeCategoryModel value, SetOptions? _) => value.toJson();

class _FirebaseIncomeCategoryRepository implements Repository<IncomeCategory> {
  final CollectionReferenceBuilder<IncomeCategoryModel>
  _collectionReferenceBuilder;
  final _firebase = FirebaseRepositoryBasicOperation<IncomeCategoryModel>();

  _FirebaseIncomeCategoryRepository._(this._collectionReferenceBuilder);

  @override
  Future<ExceptionOr<Unit>> deleteById({
    required String repoId,
    required String id,
  }) => _firebase.delete(_collectionReferenceBuilder(repoId).doc(id));

  @override
  Future<ExceptionOr<Unit>> register({
    required String repoId,
    required IncomeCategory value,
  }) => _firebase.register(
    _collectionReferenceBuilder(repoId).doc(value.id),
    IncomeCategoryModel.fromIncomeCategory(value),
  );

  @override
  Future<ExceptionOr<List<IncomeCategory>>> retrieveAll({
    required String repoId,
  }) async {
    final models = await _firebase.retrieveAll(
      _collectionReferenceBuilder(repoId),
      'name',
    );
    List<IncomeCategory> toCategories(List<IncomeCategoryModel> list) =>
        list.map<IncomeCategory>((item) => item.toEntity()).toList();
    return models.map(toCategories);
  }

  @override
  Future<ExceptionOr<IncomeCategory>> retrieveById({
    required String repoId,
    required String id,
  }) async {
    final docRef = _collectionReferenceBuilder(repoId).doc(id);
    final exceptionOrModel = await _firebase.retrieve(docRef);
    IncomeCategory toCategory(IncomeCategoryModel model) => model.toEntity();
    return exceptionOrModel.map(toCategory);
  }

  @override
  Future<ExceptionOr<Unit>> update({
    required String repoId,
    required IncomeCategory newValue,
  }) => _firebase.update(
    _collectionReferenceBuilder(repoId).doc(newValue.id),
    IncomeCategoryModel.fromIncomeCategory(newValue),
  );
}
