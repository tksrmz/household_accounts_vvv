import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:household_accounts/data/firebase/util/document_snapshot.dart';

import '../../entity/record_entity.dart';
import '../../feature/repository/record_repository.dart';
import '../../util/type/exception_or.dart';
import '../../util/type/json.dart';
import 'record_model.dart';
import 'util/path_builder.dart';
import 'util/type/collection_reference_builder.dart';

class FirebasePersonalIncomeRecordRepository
    extends _FirebaseIncomeRecordRepository
    implements PersonalIncomeRecordRepository {
  FirebasePersonalIncomeRecordRepository()
      : super(
          (String uid) => FirebaseFirestore.instance
              .collection(getPersonalIncomeRecordCollectionPath(uid))
              .withConverter(
                fromFirestore: _fromFirestore,
                toFirestore: _toFirestore,
              ),
        );
}

class FirebaseSharedIncomeRecordRepository
    extends _FirebaseIncomeRecordRepository
    implements SharedIncomeRecordRepository {
  FirebaseSharedIncomeRecordRepository()
      : super(
          (String uid) => FirebaseFirestore.instance
              .collection(getSharedIncomeRecordCollectionPath(uid))
              .withConverter(
                fromFirestore: _fromFirestore,
                toFirestore: _toFirestore,
              ),
        );
}

abstract class _FirebaseIncomeRecordRepository
    extends RecordRepository<IncomeRecord> {
  final CollectionReferenceBuilder<IncomeRecordModel> _builder;

  _FirebaseIncomeRecordRepository(this._builder);

  @override
  Future<ExceptionOr<Unit>> deleteById({
    required String repoId,
    required String id,
  }) async {
    TransactionHandler handler = (Transaction transaction) async {
      final recordDocument = _builder(repoId).doc(id);
      // Get the document
      DocumentSnapshot<IncomeRecordModel> snapshot =
          await transaction.get(recordDocument);

      if (!snapshot.exists) {
        return;
      }

      IncomeRecordModel model = snapshot.data()!;
      transaction.update(
        model.propertyRef,
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
    required IncomeRecord value,
  }) async {
    final batch = FirebaseFirestore.instance.batch();
    batch.update(
      FirebaseFirestore.instance.doc(
        '${getPersonalPropertyCollectionPath(repoId)}/${value.propertyId}',
      ),
      {
        'amount': FieldValue.increment(value.amount),
      },
    );
    batch.set(
      _builder(repoId).doc(value.id),
      IncomeRecordModel.fromEntity(
        record: value,
        categoryCollectionPath: getPersonalIncomeCategoryCollectionPath(repoId),
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
  Future<ExceptionOr<IncomeRecord>> retrieveById(
      {required String repoId, required String id}) {
    // TODO: implement retrieveById
    throw UnimplementedError();
  }

  @override
  Future<ExceptionOr<List<IncomeRecord>>> retrieveRecordsOf({
    required String repoId,
    required DateTime begin,
    required DateTime end,
  }) async {
    assert(
      begin.isBefore(end),
      '$begin is after or at the same moment as $end',
    );

    try {
      final List<IncomeRecord> incomeModels = await _builder(repoId)
          .where('date', isGreaterThanOrEqualTo: begin)
          .where('date', isLessThan: end)
          .get()
          .then(
            (QuerySnapshot<IncomeRecordModel> querySnapshot) => List.of(
              querySnapshot.docs.map(
                (queryDocumentSnapshot) =>
                    queryDocumentSnapshot.data().toEntity(),
              ),
            ),
          );
      return Right([...incomeModels]);
    } on FirebaseException catch (e) {
      print(e);
      return Left(e);
    }
  }

  @override
  Future<ExceptionOr<Unit>> update(
      {required String repoId, required IncomeRecord newValue}) {
    // TODO: implement update
    throw UnimplementedError();
  }
}

final _fromFirestore = (
  DocumentSnapshot<Json> snapshot,
  SnapshotOptions? _,
) =>
    IncomeRecordModel.fromJson(snapshot.toJsonWithId());

final _toFirestore = (
  IncomeRecordModel value,
  SetOptions? _,
) =>
    value.toJson();
