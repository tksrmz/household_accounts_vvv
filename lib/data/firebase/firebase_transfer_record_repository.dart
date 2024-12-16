import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:household_accounts/data/firebase/util/document_snapshot.dart';

import '../../entity/record.dart';
import '../../feature/repository/record_repository.dart';
import '../../util/constant/firebase_constant.dart';
import '../../util/type/exception_or.dart';
import '../../util/type/json.dart';
import 'record_model.dart';
import 'util/path_builder.dart';
import 'util/type/collection_reference_builder.dart';

class FirebasePersonalTransferRecordRepository
    implements PersonalTransferRecordRepository {
  final _TransferRecordRepository _repository;

  FirebasePersonalTransferRecordRepository()
      : _repository = _TransferRecordRepository(
          (String uid) => FirebaseFirestore.instance
              .collection(getPersonalTransferRecordCollectionPath(uid))
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
    required TransferRecord value,
  }) =>
      _repository.register(
        repoId: repoId,
        value: value,
      );

  @override
  Future<ExceptionOr<List<TransferRecord>>> retrieveAll({
    required String repoId,
  }) {
    throw UnsupportedError("DO NOT TRY TO RETRIEVE ALL THE REOCRDS.");
  }

  @override
  Future<ExceptionOr<TransferRecord>> retrieveById({
    required String repoId,
    required String id,
  }) {
    // TODO: implement retrieveById
    throw UnimplementedError();
  }

  @override
  Future<ExceptionOr<List<TransferRecord>>> retrieveRecordsOf({
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
    required TransferRecord newValue,
  }) {
    // TODO: implement update
    throw UnimplementedError();
  }
}

class FirebaseSharedTransferRecordRepository
    implements SharedTransferRecordRepository {
  final _TransferRecordRepository _repository;

  FirebaseSharedTransferRecordRepository()
      : _repository = _TransferRecordRepository(
          (String uid) => FirebaseFirestore.instance
              .collection(getPersonalTransferRecordCollectionPath(uid))
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
    required TransferRecord value,
  }) =>
      _repository.register(
        repoId: repoId,
        value: value,
      );

  @override
  Future<ExceptionOr<List<TransferRecord>>> retrieveAll({
    required String repoId,
  }) {
    throw UnsupportedError("DO NOT TRY TO RETRIEVE ALL THE REOCRDS.");
  }

  @override
  Future<ExceptionOr<TransferRecord>> retrieveById({
    required String repoId,
    required String id,
  }) {
    // TODO: implement retrieveById
    throw UnimplementedError();
  }

  @override
  Future<ExceptionOr<List<TransferRecord>>> retrieveRecordsOf({
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
    required TransferRecord newValue,
  }) {
    // TODO: implement update
    throw UnimplementedError();
  }
}

class _TransferRecordRepository {
  final CollectionReferenceBuilder<TransferRecordModel> _builder;

  _TransferRecordRepository(this._builder);

  Future<ExceptionOr<Unit>> deleteById({
    required String repoId,
    required String id,
  }) async {
    TransactionHandler handler = (Transaction transaction) async {
      final recordDocument = _builder(repoId).doc(id);
      // Get the document
      DocumentSnapshot<TransferRecordModel> snapshot =
          await transaction.get(recordDocument);

      if (!snapshot.exists) {
        return;
      }

      TransferRecordModel model = snapshot.data()!;
      if (model.hasCheckedOut) {
        transaction.update(
          model.fromPropertyRef,
          {
            'amount': FieldValue.increment(model.amount),
          },
        ).update(
          model.toPropertyRef,
          {
            'amount': FieldValue.increment(-model.amount),
          },
        );
      }
      transaction.delete(recordDocument);
      return;
    };
    try {
      await FirebaseFirestore.instance.runTransaction(handler);
      return Right(unit);
    } on FirebaseException catch (e) {
      print(e);
      return Left(e);
    }
  }

  Future<ExceptionOr<Unit>> register({
    required String repoId,
    required TransferRecord value,
  }) async {
    final ownerDocument = _builder(repoId).parent!;
    final propertyCollection =
        ownerDocument.collection(FIREBASE_COLLECTION_PROPERTIES);
    final batch = FirebaseFirestore.instance.batch();
    if (value.hasCheckedOut) {
      batch
        ..update(
          propertyCollection.doc(value.source.id),
          {
            'amount': FieldValue.increment(-value.amount),
          },
        )
        ..update(
          propertyCollection.doc(value.destination.id),
          {
            'amount': FieldValue.increment(value.amount),
          },
        );
    }
    batch.set(
      _builder(repoId).doc(value.id),
      TransferRecordModel.fromEntity(
        record: value,
        propertyCollectionPath: propertyCollection.path,
      ),
    );

    try {
      await batch.commit();
      return Right(unit);
    } on FirebaseException catch (e) {
      print(e);
      return Left(e);
    }
  }

  Future<ExceptionOr<List<TransferRecord>>> retrieveRecordsOf({
    required String repoId,
    required DateTime begin,
    required DateTime end,
  }) async {
    assert(
      begin.isBefore(end),
      '$begin is after or at the same moment as $end',
    );

    final QuerySnapshot<TransferRecordModel> querySnapshot;
    try {
      querySnapshot = await _builder(repoId)
          .where('date', isGreaterThanOrEqualTo: begin)
          .where('date', isLessThan: end)
          .get();
    } on FirebaseException catch (e) {
      print(e);
      return Left(e);
    }

    final toModel = (QueryDocumentSnapshot<TransferRecordModel> snapshot) =>
        snapshot.data();
    final models = querySnapshot.docs.map(toModel);
    final toEntityAsync = (TransferRecordModel model) => model.toEntityAsync();
    final entityList = await Future.wait(models.map(toEntityAsync));
    return Right(entityList);
  }
}

final _fromFirestore = (
  DocumentSnapshot<Json> snapshot,
  SnapshotOptions? _,
) =>
    TransferRecordModel.fromJson(snapshot.toJsonWithId());

final _toFirestore = (
  TransferRecordModel value,
  SetOptions? _,
) =>
    value.toJson();
