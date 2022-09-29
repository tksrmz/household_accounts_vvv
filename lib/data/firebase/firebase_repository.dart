import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../util/type/exception.dart';
import '../../util/type/exception_or.dart';
import '../../util/type/identifiable.dart';
import '../../util/type/json.dart';

/// Basic firebase repository operation.
///
/// This class provides the following operations.
///
/// - Create a record ([register])
/// - Read a record ([retrieveById])
/// - Read all records ([retrieveAll])
/// - Update a record ([update])
/// - Delete a record ([deleteById])
///
/// [E] is an entity class, and [M] is a model class of [E].
class FirebaseRepositoryBasicOperation<E extends Identifiable, M extends E> {
  Future<ExceptionOr<Unit>> register({
    required CollectionReference<M> ref,
    required E entity,
    required M Function(E) entityToModel,
  }) async {
    try {
      await ref.doc(entity.id).set(entityToModel(entity));
    } on FirebaseException catch (e) {
      print(e);
      return Left(e);
    }

    return Right(unit);
  }

  Future<ExceptionOr<E>> retrieveById({
    required CollectionReference<M> ref,
    required String id,
  }) async {
    final DocumentSnapshot<M> snapshot;
    try {
      snapshot = await ref.doc(id).get();
    } on FirebaseException catch (e) {
      print(e);
      return Left(e);
    }

    if (!snapshot.exists) {
      return Left(
        RepositoryException(
          'Any records in the repository do not have ID %id',
        ),
      );
    }

    return Right(snapshot.data()!);
  }

  Future<ExceptionOr<List<E>>> retrieveAll({
    required CollectionReference<M> ref,
    String? sortKey,
  }) async {
    final QuerySnapshot<M> snapshot;
    try {
      snapshot = sortKey == null
          ? (await ref.get())
          : (await ref.orderBy(sortKey).get());
    } on FirebaseException catch (e) {
      print(e);
      return Left(e);
    }

    return Right(
      List.of(
        snapshot.docs.map(
          (document) => document.data(),
        ),
      ),
    );
  }

  Future<ExceptionOr<Unit>> update({
    required CollectionReference<M> ref,
    required E newValue,
    required Json Function(E) entityToJson,
  }) async {
    final newValueJson = entityToJson(newValue);
    try {
      await ref.doc(newValue.id).update(newValueJson);
    } on FirebaseException catch (e) {
      print(e);
      return Left(e);
    }

    return Right(unit);
  }

  Future<ExceptionOr<Unit>> deleteById({
    required CollectionReference<M> ref,
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
}
