import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../entity/record_entity.dart';
import '../../feature/repository/record_repository.dart';
import '../../util/type/exception_or.dart';
import 'record_model.dart';
import 'util/path_builder.dart';
import 'util/type/collection_reference_builder.dart';

class FirebaseTransferRecordRepository
    extends PersonalTransferRecordRepository {
  final CollectionReferenceBuilder<TransferRecordModel> _builder =
      (String uid) => FirebaseFirestore.instance
          .collection(getPersonalTransferRecordCollectionPath(uid))
          .withConverter(
            fromFirestore: _fromFirestore,
            toFirestore: _toFirestore,
          );

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
    final batch = FirebaseFirestore.instance.batch();
    batch.update(
      FirebaseFirestore.instance.doc(
          '${getPersonalPropertyCollectionPath(repoId)}/${value.srcPropertyId}'),
      {
        'amount': FieldValue.increment(-value.amount),
      },
    );
    batch.update(
      FirebaseFirestore.instance.doc(
          '${getPersonalPropertyCollectionPath(repoId)}/${value.destPropertyId}'),
      {
        'amount': FieldValue.increment(value.amount),
      },
    );
    batch.set(
      _builder(repoId).doc(value.id),
      TransferRecordModel.fromTransferRecord(
        record: value,
        propertyCollectionPath: getPersonalPropertyCollectionPath(repoId),
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

    try {
      final List<TransferRecord> models = await _builder(repoId)
          .where('date', isGreaterThanOrEqualTo: begin)
          .where('date', isLessThan: end)
          .get()
          .then(
            (QuerySnapshot<TransferRecordModel> querySnapshot) => List.of(
              querySnapshot.docs.map(
                (queryDocumentSnapshot) => queryDocumentSnapshot.data(),
              ),
            ),
          );
      return Right([...models]);
    } on FirebaseException catch (e) {
      print(e);
      return Left(e);
    }
  }

  @override
  Future<ExceptionOr<Unit>> update(
      {required String repoId, required TransferRecord newValue}) {
    // TODO: implement update
    throw UnimplementedError();
  }
}

final _fromFirestore = (
  DocumentSnapshot<Map<String, dynamic>> snapshot,
  SnapshotOptions? _,
) =>
    TransferRecordModel.fromIdAndJson(
      id: snapshot.id,
      json: snapshot.data()!,
    );

final _toFirestore = (
  TransferRecordModel value,
  SetOptions? _,
) =>
    value.toJson();
