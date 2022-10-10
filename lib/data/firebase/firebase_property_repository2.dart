import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../entity/property_entity.dart';
import '../../feature/repository/property_repository.dart';
import '../../util/type/exception_or.dart';
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

final _fromFirestore = (
  DocumentSnapshot<Map<String, dynamic>> snapshot,
  SnapshotOptions? _,
) =>
    PropertyModel.fromIdAndJson(
      snapshot.id,
      snapshot.data()!,
    );

final _toFirestore = (
  PropertyModel value,
  SetOptions? _,
) =>
    value.toJson();

class _FirebasePropertyRepository implements Repository2<Property> {
  final CollectionReferenceBuilder<PropertyModel> _collectionReferenceBuilder;
  final _operation =
      FirebaseRepositoryBasicOperation<Property, PropertyModel>();

  _FirebasePropertyRepository._(this._collectionReferenceBuilder);

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
    required Property value,
  }) =>
      _operation.register(
        ref: _collectionReferenceBuilder(repoId),
        entity: value,
        entityToModel: PropertyModel.fromProperty,
      );

  @override
  Future<ExceptionOr<List<Property>>> retrieveAll({
    required String repoId,
  }) =>
      _operation.retrieveAll(
        ref: _collectionReferenceBuilder(repoId),
        sortKey: 'name',
      );

  @override
  Future<ExceptionOr<Property>> retrieveById({
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
    required Property newValue,
  }) {
    final toJson =
        (Property property) => PropertyModel.fromProperty(property).toJson();

    return _operation.update(
      ref: _collectionReferenceBuilder(repoId),
      newValue: newValue,
      entityToJson: toJson,
    );
  }
}
