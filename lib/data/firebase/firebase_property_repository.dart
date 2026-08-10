import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:household_accounts/data/firebase/util/document_snapshot.dart';

import '../../entity/property.dart';
import '../../feature/repository/property_repository.dart';
import '../../util/type/exception_or.dart';
import '../../util/type/json.dart';
import '../../util/type/repository.dart';
import 'firebase_repository.dart';
import 'property_model.dart';
import 'util/path_builder.dart';
import 'util/type/collection_reference_builder.dart';

class FirebasePersonalPropertyRepository extends _FirebasePropertyRepository
    implements PersonalPropertyRepository {
  FirebasePersonalPropertyRepository()
    : super._(
        (String uid) => FirebaseFirestore.instance
            .collection(getPersonalPropertyCollectionPath(uid))
            .withConverter<PropertyModel>(
              fromFirestore: _fromFirestore,
              toFirestore: _toFirestore,
            ),
      );
}

class FirebaseSharedPropertyRepository extends _FirebasePropertyRepository
    implements SharedPropertyRepository {
  FirebaseSharedPropertyRepository()
    : super._(
        (String pairId) => FirebaseFirestore.instance
            .collection(getSharedPropertyCollectionPath(pairId))
            .withConverter<PropertyModel>(
              fromFirestore: _fromFirestore,
              toFirestore: _toFirestore,
            ),
      );
}

PropertyModel _fromFirestore(
  DocumentSnapshot<Json> snapshot,
  SnapshotOptions? _,
) => PropertyModel.fromJson(snapshot.toJsonWithId());

Json _toFirestore(PropertyModel value, SetOptions? _) => value.toJson();

class _FirebasePropertyRepository implements Repository<Property> {
  final CollectionReferenceBuilder<PropertyModel> _collectionReferenceBuilder;
  final _firebase = FirebaseRepositoryBasicOperation<PropertyModel>();

  _FirebasePropertyRepository._(this._collectionReferenceBuilder);

  @override
  Future<ExceptionOr<Unit>> deleteById({
    required String repoId,
    required String id,
  }) => _firebase.delete(_collectionReferenceBuilder(repoId).doc(id));

  @override
  Future<ExceptionOr<Unit>> register({
    required String repoId,
    required Property value,
  }) => _firebase.register(
    _collectionReferenceBuilder(repoId).doc(value.id),
    PropertyModel.fromEntity(value),
  );

  @override
  Future<ExceptionOr<List<Property>>> retrieveAll({
    required String repoId,
  }) async {
    final exceptionOrModelList = await _firebase.retrieveAll(
      _collectionReferenceBuilder(repoId),
      'name',
    );
    List<Property> toProperties(List<PropertyModel> list) =>
        list.map<Property>((item) => item.toEntity()).toList();
    return exceptionOrModelList.map(toProperties);
  }

  @override
  Future<ExceptionOr<Property>> retrieveById({
    required String repoId,
    required String id,
  }) async {
    final docRef = _collectionReferenceBuilder(repoId).doc(id);
    final exceptionOrModel = await _firebase.retrieve(docRef);
    Property toProperty(PropertyModel model) => model.toEntity();
    return exceptionOrModel.map(toProperty);
  }

  @override
  Future<ExceptionOr<Unit>> update({
    required String repoId,
    required Property newValue,
  }) => _firebase.update(
    _collectionReferenceBuilder(repoId).doc(newValue.id),
    PropertyModel.fromEntity(newValue),
  );
}
