import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../util/type/exception.dart';
import '../../util/type/exception_or.dart';
import 'data_model.dart';

/// Basic firebase repository operation.
///
/// This class provides the following operations.
///
/// - Create a record ([register])
/// - Read a record ([retrieveById])
/// - Read all records ([retrieveAll])
/// - Update a record ([update])
/// - Delete a record ([deleteById])
class FirebaseRepositoryBasicOperation<M extends DataModel> {
  Future<ExceptionOr<Unit>> register(DocumentReference<M> ref, M value) async {
    try {
      await ref.set(value);
    } on FirebaseException catch (e) {
      debugPrint('$e');
      return Left(e);
    }

    return Right(unit);
  }

  Future<ExceptionOr<M>> retrieve(DocumentReference<M> ref) async {
    final DocumentSnapshot<M> snapshot;
    try {
      snapshot = await ref.get();
    } on FirebaseException catch (e) {
      debugPrint('$e');
      return Left(e);
    }

    if (!snapshot.exists) {
      return Left(
        RepositoryException(
          'Any records in the repository do not have ID ${ref.id}',
        ),
      );
    }

    return Right(snapshot.data()!);
  }

  Future<ExceptionOr<List<M>>> retrieveAll(
    CollectionReference<M> ref, [
    String? sortKey,
  ]) async {
    final QuerySnapshot<M> snapshot;
    try {
      snapshot = sortKey == null
          ? (await ref.get())
          : (await ref.orderBy(sortKey).get());
    } on FirebaseException catch (e) {
      debugPrint('$e');
      return Left(e);
    }

    M snapshotToData(QueryDocumentSnapshot<M> snapshot) => snapshot.data();
    return Right(snapshot.docs.map(snapshotToData).toList());
  }

  Future<ExceptionOr<Unit>> update(DocumentReference<M> ref, M value) async {
    try {
      await ref.update(value.toJson());
    } on FirebaseException catch (e) {
      debugPrint('$e');
      return Left(e);
    }

    return Right(unit);
  }

  Future<ExceptionOr<Unit>> delete(DocumentReference<M> ref) async {
    try {
      await ref.delete();
    } on FirebaseException catch (e) {
      debugPrint('$e');
      return Left(e);
    }

    return Right(unit);
  }
}
