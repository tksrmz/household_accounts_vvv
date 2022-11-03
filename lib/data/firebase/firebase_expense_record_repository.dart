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

class FirebasePersonalExpenseRecordRepository
    extends _FirebaseExpenseRecordRepository
    implements PersonalExpenseRecordRepository {
  FirebasePersonalExpenseRecordRepository()
      : super(
          (String uid) => FirebaseFirestore.instance
              .collection(getPersonalExpenseRecordCollectionPath(uid))
              .withConverter(
                fromFirestore: _fromFirestore,
                toFirestore: _toFirestore,
              ),
        );
}

class FirebaseSharedExpenseRecordRepository
    extends _FirebaseExpenseRecordRepository
    implements SharedExpenseRecordRepository {
  FirebaseSharedExpenseRecordRepository()
      : super(
          (String uid) => FirebaseFirestore.instance
              .collection(getSharedExpenseRecordCollectionPath(uid))
              .withConverter(
                fromFirestore: _fromFirestore,
                toFirestore: _toFirestore,
              ),
        );
}

abstract class _FirebaseExpenseRecordRepository
    extends RecordRepository<ExpenseRecord> {
  final CollectionReferenceBuilder<ExpenseRecordModel> _builder;

  _FirebaseExpenseRecordRepository(this._builder);

  @override
  Future<ExceptionOr<Unit>> deleteById({
    required String repoId,
    required String id,
  }) async {
    TransactionHandler handler = (Transaction transaction) async {
      final recordDocument = _builder(repoId).doc(id);
      // Get the document
      DocumentSnapshot<ExpenseRecordModel> snapshot =
          await transaction.get(recordDocument);

      if (!snapshot.exists) {
        return;
      }

      ExpenseRecordModel model = snapshot.data()!;
      transaction.update(
        model.propertyRef,
        {
          'amount': FieldValue.increment(model.amount),
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
    required ExpenseRecord value,
  }) async {
    final ownerDocument = _builder(repoId).parent!;
    final propertyCollection =
        ownerDocument.collection(FIREBASE_COLLECTION_PROPERTIES);
    final categoryCollection =
        ownerDocument.collection(FIREBASE_COLLECTION_EXPENSE_CATEGORIES);
    final batch = FirebaseFirestore.instance.batch()
      ..update(
        propertyCollection.doc(value.property.id),
        {
          'amount': FieldValue.increment(-value.amount),
        },
      )
      ..set(
        _builder(repoId).doc(value.id),
        ExpenseRecordModel.fromEntity(
          record: value,
          categoryCollectionPath: categoryCollection.path,
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
  Future<ExceptionOr<ExpenseRecord>> retrieveById(
      {required String repoId, required String id}) {
    // TODO: implement retrieveById
    throw UnimplementedError();
  }

  @override
  Future<ExceptionOr<List<ExpenseRecord>>> retrieveRecordsOf({
    required String repoId,
    required DateTime begin,
    required DateTime end,
  }) async {
    assert(
      begin.isBefore(end),
      '$begin is after or at the same moment as $end',
    );

    final QuerySnapshot<ExpenseRecordModel> querySnapshot;
    try {
      querySnapshot = await _builder(repoId)
          .where('date', isGreaterThanOrEqualTo: begin)
          .where('date', isLessThan: end)
          .get();
    } on FirebaseException catch (e) {
      print(e);
      return Left(e);
    }

    final toModel =
        (QueryDocumentSnapshot<ExpenseRecordModel> snapshot) => snapshot.data();
    final models = querySnapshot.docs.map(toModel);
    final toEntityAsync = (ExpenseRecordModel model) => model.toEntityAsync();
    final entityList = await Future.wait(models.map(toEntityAsync));
    return Right(entityList);
  }

  @override
  Future<ExceptionOr<Unit>> update(
      {required String repoId, required ExpenseRecord newValue}) {
    // TODO: implement update
    throw UnimplementedError();
  }
}

final _fromFirestore = (
  DocumentSnapshot<Json> snapshot,
  SnapshotOptions? _,
) =>
    ExpenseRecordModel.fromJson(snapshot.toJsonWithId());

final _toFirestore = (
  ExpenseRecordModel value,
  SetOptions? _,
) =>
    value.toJson();
