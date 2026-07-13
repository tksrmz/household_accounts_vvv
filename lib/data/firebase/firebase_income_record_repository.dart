import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:household_accounts/data/firebase/util/document_snapshot.dart';

import '../../entity/record.dart';
import '../../feature/repository/record_repository.dart';
import '../../util/constant/firebase_constant.dart';
import '../../util/type/exception_or.dart';
import '../../util/type/json.dart';
import 'record_model.dart';
import 'util/path_builder.dart';
import 'util/type/collection_reference_builder.dart';

class FirebasePersonalIncomeRecordRepository
    implements PersonalIncomeRecordRepository {
  final _IncomeRecordRepository _repository;

  FirebasePersonalIncomeRecordRepository()
      : _repository = _IncomeRecordRepository(
          (String uid) => FirebaseFirestore.instance
              .collection(getPersonalIncomeRecordCollectionPath(uid))
              .withConverter(
                fromFirestore: _fromFirestore,
                toFirestore: _toFirestore,
              ),
        );

  @override
  Future<ExceptionOr<Unit>> deleteById({
    required String repoId,
    required String id,
  }) =>
      _repository.deleteById(
        repoId: repoId,
        id: id,
      );

  @override
  Future<ExceptionOr<Unit>> register({
    required String repoId,
    required IncomeRecord value,
  }) =>
      _repository.register(
        repoId: repoId,
        value: value,
      );

  @override
  Future<ExceptionOr<List<IncomeRecord>>> retrieveAll({
    required String repoId,
  }) {
    throw UnsupportedError("DO NOT TRY TO RETRIEVE ALL THE REOCRDS.");
  }

  @override
  Future<ExceptionOr<IncomeRecord>> retrieveById({
    required String repoId,
    required String id,
  }) {
    // TODO: implement retrieveById
    throw UnimplementedError();
  }

  @override
  Future<ExceptionOr<List<IncomeRecord>>> retrieveRecordsOf({
    required String repoId,
    required DateTime begin,
    required DateTime end,
  }) =>
      _repository.retrieveRecordsOf(
        repoId: repoId,
        begin: begin,
        end: end,
      );

  @override
  Future<ExceptionOr<Unit>> update({
    required String repoId,
    required IncomeRecord newValue,
  }) {
    // TODO: implement update
    throw UnimplementedError();
  }
}

class FirebaseSharedIncomeRecordRepository
    implements SharedIncomeRecordRepository {
  final _IncomeRecordRepository _repository;

  FirebaseSharedIncomeRecordRepository()
      : _repository = _IncomeRecordRepository(
          (String uid) => FirebaseFirestore.instance
              .collection(getSharedIncomeRecordCollectionPath(uid))
              .withConverter(
                fromFirestore: _fromFirestore,
                toFirestore: _toFirestore,
              ),
        );

  @override
  Future<ExceptionOr<Unit>> deleteById({
    required String repoId,
    required String id,
  }) =>
      _repository.deleteById(
        repoId: repoId,
        id: id,
      );

  @override
  Future<ExceptionOr<Unit>> register({
    required String repoId,
    required IncomeRecord value,
  }) =>
      _repository.register(
        repoId: repoId,
        value: value,
      );

  @override
  Future<ExceptionOr<List<IncomeRecord>>> retrieveAll({
    required String repoId,
  }) {
    throw UnsupportedError("DO NOT TRY TO RETRIEVE ALL THE REOCRDS.");
  }

  @override
  Future<ExceptionOr<IncomeRecord>> retrieveById({
    required String repoId,
    required String id,
  }) {
    // TODO: implement retrieveById
    throw UnimplementedError();
  }

  @override
  Future<ExceptionOr<List<IncomeRecord>>> retrieveRecordsOf({
    required String repoId,
    required DateTime begin,
    required DateTime end,
  }) =>
      _repository.retrieveRecordsOf(
        repoId: repoId,
        begin: begin,
        end: end,
      );

  @override
  Future<ExceptionOr<Unit>> update({
    required String repoId,
    required IncomeRecord newValue,
  }) {
    // TODO: implement update
    throw UnimplementedError();
  }
}

class _IncomeRecordRepository {
  final CollectionReferenceBuilder<IncomeRecordModel> _builder;

  _IncomeRecordRepository(this._builder);

  Future<ExceptionOr<Unit>> deleteById({
    required String repoId,
    required String id,
  }) async {
    Future<void> handler(Transaction transaction) async {
      final recordDocument = _builder(repoId).doc(id);
      // Get the document
      final DocumentSnapshot<IncomeRecordModel> snapshot =
          await transaction.get(recordDocument);

      if (!snapshot.exists) {
        return;
      }

      IncomeRecordModel model = snapshot.data()!;
      if (model.hasCheckedOut) {
        // Restore property
        transaction.update(
          model.propertyRef,
          {
            'amount': FieldValue.increment(-model.amount),
          },
        );
      }
      transaction.delete(recordDocument);
      return;
    }

    try {
      await FirebaseFirestore.instance.runTransaction(handler);
      return Right(unit);
    } on FirebaseException catch (e) {
      debugPrint('$e');
      return Left(e);
    }
  }

  Future<ExceptionOr<Unit>> register({
    required String repoId,
    required IncomeRecord value,
  }) async {
    final ownerDocument = _builder(repoId).parent!;
    final propertyCollection =
        ownerDocument.collection(firebaseCollectionProperties);
    final categoryCollection =
        ownerDocument.collection(firebaseCollectionIncomeCategories);
    final batch = FirebaseFirestore.instance.batch();
    if (value.hasCheckedOut) {
      batch.update(
        propertyCollection.doc(value.property.id),
        {
          'amount': FieldValue.increment(value.amount),
        },
      );
    }
    batch.set(
      _builder(repoId).doc(value.id),
      IncomeRecordModel.fromEntity(
        record: value,
        categoryCollectionPath: categoryCollection.path,
        propertyCollectionPath: propertyCollection.path,
      ),
    );

    try {
      await batch.commit();
      return Right(unit);
    } on FirebaseException catch (e) {
      debugPrint('$e');
      return Left(e);
    }
  }

  Future<ExceptionOr<List<IncomeRecord>>> retrieveRecordsOf({
    required String repoId,
    required DateTime begin,
    required DateTime end,
  }) async {
    assert(
      begin.isBefore(end),
      '$begin is after or at the same moment as $end',
    );

    final QuerySnapshot<IncomeRecordModel> querySnapshot;
    try {
      querySnapshot = await _builder(repoId)
          .where('date', isGreaterThanOrEqualTo: begin)
          .where('date', isLessThan: end)
          .get();
    } on FirebaseException catch (e) {
      debugPrint('$e');
      return Left(e);
    }

    IncomeRecordModel toModel(
            QueryDocumentSnapshot<IncomeRecordModel> snapshot) =>
        snapshot.data();
    final models = querySnapshot.docs.map(toModel);
    Future<IncomeRecord> toEntityAsync(IncomeRecordModel model) =>
        model.toEntityAsync();
    final entityList = await Future.wait(models.map(toEntityAsync));
    return Right(entityList);
  }
}

IncomeRecordModel _fromFirestore(
  DocumentSnapshot<Json> snapshot,
  SnapshotOptions? _,
) =>
    IncomeRecordModel.fromJson(snapshot.toJsonWithId());

Json _toFirestore(
  IncomeRecordModel value,
  SetOptions? _,
) =>
    value.toJson();
