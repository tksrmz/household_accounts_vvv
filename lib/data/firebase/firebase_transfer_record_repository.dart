import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:household_accounts/data/firebase/util/document_snapshot.dart';

import '../../entity/record_entity.dart';
import '../../feature/repository/record_repository.dart';
import '../../util/constant/firebase_constant.dart';
import '../../util/type/exception_or.dart';
import '../../util/type/json.dart';
import 'record_model.dart';
import 'util/path_builder.dart';
import 'util/type/collection_reference_builder.dart';

class FirebasePersonalTransferRecordRepository
    extends _FirebaseTransferRecordRepository
    implements PersonalTransferRecordRepository {
  FirebasePersonalTransferRecordRepository()
      : super(
          (String uid) => FirebaseFirestore.instance
              .collection(getPersonalTransferRecordCollectionPath(uid))
              .withConverter(
                fromFirestore: _fromFirestore,
                toFirestore: _toFirestore,
              ),
        );
}

class FirebaseSharedTransferRecordRepository
    extends _FirebaseTransferRecordRepository
    implements SharedTransferRecordRepository {
  FirebaseSharedTransferRecordRepository()
      : super(
          (String uid) => FirebaseFirestore.instance
              .collection(getSharedTransferRecordCollectionPath(uid))
              .withConverter(
                fromFirestore: _fromFirestore,
                toFirestore: _toFirestore,
              ),
        );
}

class _FirebaseTransferRecordRepository
    extends RecordRepository<TransferRecord> {
  final CollectionReferenceBuilder<TransferRecordModel> _builder;

  _FirebaseTransferRecordRepository(this._builder);

  @override
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
      ).delete(recordDocument);
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

  @override
  Future<ExceptionOr<Unit>> register({
    required String repoId,
    required TransferRecord value,
  }) async {
    final ownerDocument = _builder(repoId).parent!;
    final propertyCollection =
        ownerDocument.collection(FIREBASE_COLLECTION_PROPERTIES);
    final batch = FirebaseFirestore.instance.batch()
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

  @override
  Future<ExceptionOr<TransferRecord>> retrieveById(
      {required String repoId, required String id}) {
    // TODO: implement retrieveById
    throw UnimplementedError();
  }

  @override
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

  @override
  Future<ExceptionOr<Unit>> update(
      {required String repoId, required TransferRecord newValue}) {
    // TODO: implement update
    throw UnimplementedError();
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
