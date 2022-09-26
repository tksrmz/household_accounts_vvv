import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../entity/property_entity.dart';
import '../../feature/repository/property_repository.dart';
import '../../util/constant/firebase_constant.dart';
import '../../util/type/exception.dart';
import '../../util/type/exception_or.dart';
import 'property_model.dart';

class FirebasePersonalPropertyRepository implements PropertyRepository2 {
  final delegation = _FirebasePropertyRepository();

  @override
  Future<ExceptionOr<Unit>> deleteById({
    required String repoId,
    required String id,
  }) =>
      delegation.deleteById(
        ref: _collectionReferenceOf(repoId),
        id: id,
      );

  @override
  Future<ExceptionOr<Unit>> register({
    required String repoId,
    required Property value,
  }) =>
      delegation.register(
        ref: _collectionReferenceOf(repoId),
        value: value,
      );

  @override
  Future<ExceptionOr<List<Property>>> retrieveAll({
    required String repoId,
  }) =>
      delegation.retrieveAll(
        ref: _collectionReferenceOf(repoId),
      );

  @override
  Future<ExceptionOr<Property>> retrieveById({
    required String repoId,
    required String id,
  }) =>
      delegation.retrieveById(
        ref: _collectionReferenceOf(repoId),
        id: id,
      );

  @override
  Future<ExceptionOr<Unit>> update({
    required String repoId,
    required Property newValue,
  }) =>
      delegation.update(
        ref: _collectionReferenceOf(repoId),
        newValue: newValue,
      );

  CollectionReference<PropertyModel> _collectionReferenceOf(String uid) =>
      FirebaseFirestore.instance
          .collection(
              '/$FIREBASE_COLLECTION_PERSONAL_NOTES/$uid/$FIREBASE_COLLECTION_PROPERTIES')
          .withConverter<PropertyModel>(
            fromFirestore: (snapshot, _) {
              final json = snapshot.data()!;
              return PropertyModel.fromIdAndJson(snapshot.id, json);
            },
            toFirestore: (propertyModel, _) => propertyModel.toJson(),
          );
}

class FirebaseSharedPropertyRepository implements PropertyRepository2 {
  final delegation = _FirebasePropertyRepository();

  @override
  Future<ExceptionOr<Unit>> deleteById({
    required String repoId,
    required String id,
  }) =>
      delegation.deleteById(
        ref: _collectionReferenceOf(repoId),
        id: id,
      );

  @override
  Future<ExceptionOr<Unit>> register({
    required String repoId,
    required Property value,
  }) =>
      delegation.register(
        ref: _collectionReferenceOf(repoId),
        value: value,
      );

  @override
  Future<ExceptionOr<List<Property>>> retrieveAll({
    required String repoId,
  }) =>
      delegation.retrieveAll(
        ref: _collectionReferenceOf(repoId),
      );

  @override
  Future<ExceptionOr<Property>> retrieveById({
    required String repoId,
    required String id,
  }) =>
      delegation.retrieveById(
        ref: _collectionReferenceOf(repoId),
        id: id,
      );

  @override
  Future<ExceptionOr<Unit>> update({
    required String repoId,
    required Property newValue,
  }) =>
      delegation.update(
        ref: _collectionReferenceOf(repoId),
        newValue: newValue,
      );

  CollectionReference<PropertyModel> _collectionReferenceOf(String pairId) =>
      FirebaseFirestore.instance
          .collection(
              '/$FIREBASE_COLLECTION_SHARED_NOTES/$pairId/$FIREBASE_COLLECTION_PROPERTIES')
          .withConverter<PropertyModel>(
            fromFirestore: (snapshot, _) {
              final json = snapshot.data()!;
              return PropertyModel.fromIdAndJson(snapshot.id, json);
            },
            toFirestore: (propertyModel, _) => propertyModel.toJson(),
          );
}

class _FirebasePropertyRepository {
  Future<ExceptionOr<Unit>> deleteById({
    required CollectionReference<PropertyModel> ref,
    required String id,
  }) async {
    try {
      await ref.doc(id).delete();
    } on FirebaseException catch (e) {
      print(e);
      return Left(e);
    }
    return Right(unit);
  }

  Future<ExceptionOr<Unit>> register({
    required CollectionReference<PropertyModel> ref,
    required Property value,
  }) async {
    try {
      await ref.doc(value.id).set(PropertyModel.fromProperty(value));
    } on FirebaseException catch (e) {
      print(e);
      return Left(e);
    }
    return Right(unit);
  }

  Future<ExceptionOr<Property>> retrieveById({
    required CollectionReference<PropertyModel> ref,
    required String id,
  }) async {
    final DocumentSnapshot<PropertyModel> snapshot;
    try {
      snapshot = await ref.doc(id).get();
    } on FirebaseException catch (e) {
      print(e);
      return Left(e);
    }

    if (!snapshot.exists) {
      return Left(
        RepositoryException(
          'Property with ID $id does not exist.',
        ),
      );
    }

    return Right(snapshot.data()!);
  }

  Future<ExceptionOr<List<Property>>> retrieveAll({
    required CollectionReference<PropertyModel> ref,
  }) async {
    final QuerySnapshot<PropertyModel> snapshot;
    try {
      snapshot = await ref.orderBy('name').get();
    } on FirebaseException catch (e) {
      print(e);
      return Left(e);
    }
    return Right(
      List.of(
        snapshot.docs.map(
          (prop) => prop.data(),
        ),
      ),
    );
  }

  Future<ExceptionOr<Unit>> update({
    required CollectionReference<PropertyModel> ref,
    required Property newValue,
  }) async {
    try {
      await ref
          .doc(newValue.id)
          .update(PropertyModel.fromProperty(newValue).toJson());
    } on FirebaseException catch (e) {
      print(e);
      return Left(e);
    }
    return Right(unit);
  }
}
