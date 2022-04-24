import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:household_accounts/constants/firebase/firebase_constant.dart';
import 'package:household_accounts/features/input-page/data/models/record_model.dart';
import 'package:household_accounts/features/input-page/domain/entities/record.dart';
import 'package:household_accounts/features/input-page/domain/repositories/record_repository.dart';
import 'package:household_accounts/util/failures/failure.dart';

class FirebaseRecordRepository implements RecordRepositoryNew {
  @deprecated
  FirebaseRecordRepository.of(String uid)
      : _incomeCollectionRef = FirebaseFirestore.instance
            .collection(
                '/$FIREBASE_COLLECTION_PERSONAL_NOTES/$uid/$FIREBASE_COLLECTION_INCOMES')
            .withConverter(
              fromFirestore: (snapshot, _) => IncomeRecordModel.fromIdAndJson(
                id: snapshot.id,
                json: snapshot.data()!,
              ),
              toFirestore: (model, _) => model.toJson(),
            ),
        _expenseCollectionRef = FirebaseFirestore.instance
            .collection(
                '/$FIREBASE_COLLECTION_PERSONAL_NOTES/$uid/$FIREBASE_COLLECTION_EXPENSES')
            .withConverter(
              fromFirestore: (snapshot, _) => ExpenseRecordModel.fromIdAndJson(
                id: snapshot.id,
                json: snapshot.data()!,
              ),
              toFirestore: (model, _) => model.toJson(),
            ),
        _transferCollectionRef = FirebaseFirestore.instance
            .collection(
                '/$FIREBASE_COLLECTION_PERSONAL_NOTES/$uid/$FIREBASE_COLLECTION_TRANSFERS')
            .withConverter(
              fromFirestore: (snapshot, _) => TransferRecordModel.fromIdAndJson(
                id: snapshot.id,
                json: snapshot.data()!,
              ),
              toFirestore: (model, _) => model.toJson(),
            ),
        _propertyCollectionPath = '',
        _categoryCollectionPath = '';

  FirebaseRecordRepository.personal(String uid)
      : _incomeCollectionRef = FirebaseFirestore.instance
            .collection(
                '/$FIREBASE_COLLECTION_PERSONAL_NOTES/$uid/$FIREBASE_COLLECTION_INCOMES')
            .withConverter(
              fromFirestore: (snapshot, _) => IncomeRecordModel.fromIdAndJson(
                id: snapshot.id,
                json: snapshot.data()!,
              ),
              toFirestore: (model, _) => model.toJson(),
            ),
        _expenseCollectionRef = FirebaseFirestore.instance
            .collection(
                '/$FIREBASE_COLLECTION_PERSONAL_NOTES/$uid/$FIREBASE_COLLECTION_EXPENSES')
            .withConverter(
              fromFirestore: (snapshot, _) => ExpenseRecordModel.fromIdAndJson(
                id: snapshot.id,
                json: snapshot.data()!,
              ),
              toFirestore: (model, _) => model.toJson(),
            ),
        _transferCollectionRef = FirebaseFirestore.instance
            .collection(
                '/$FIREBASE_COLLECTION_PERSONAL_NOTES/$uid/$FIREBASE_COLLECTION_TRANSFERS')
            .withConverter(
              fromFirestore: (snapshot, _) => TransferRecordModel.fromIdAndJson(
                id: snapshot.id,
                json: snapshot.data()!,
              ),
              toFirestore: (model, _) => model.toJson(),
            ),
        _propertyCollectionPath =
            '/$FIREBASE_COLLECTION_PERSONAL_NOTES/$uid/$FIREBASE_COLLECTION_PROPERTIES',
        _categoryCollectionPath =
            '/$FIREBASE_COLLECTION_PERSONAL_NOTES/$uid/$FIREBASE_COLLECTION_CATEGORIES';

  FirebaseRecordRepository.shared(String pairId)
      : _incomeCollectionRef = FirebaseFirestore.instance
            .collection(
                '/$FIREBASE_COLLECTION_SHARED_NOTES/$pairId/$FIREBASE_COLLECTION_INCOMES')
            .withConverter(
              fromFirestore: (snapshot, _) => IncomeRecordModel.fromIdAndJson(
                id: snapshot.id,
                json: snapshot.data()!,
              ),
              toFirestore: (model, _) => model.toJson(),
            ),
        _expenseCollectionRef = FirebaseFirestore.instance
            .collection(
                '/$FIREBASE_COLLECTION_SHARED_NOTES/$pairId/$FIREBASE_COLLECTION_EXPENSES')
            .withConverter(
              fromFirestore: (snapshot, _) => ExpenseRecordModel.fromIdAndJson(
                id: snapshot.id,
                json: snapshot.data()!,
              ),
              toFirestore: (model, _) => model.toJson(),
            ),
        _transferCollectionRef = FirebaseFirestore.instance
            .collection(
                '/$FIREBASE_COLLECTION_SHARED_NOTES/$pairId/$FIREBASE_COLLECTION_TRANSFERS')
            .withConverter(
              fromFirestore: (snapshot, _) => TransferRecordModel.fromIdAndJson(
                id: snapshot.id,
                json: snapshot.data()!,
              ),
              toFirestore: (model, _) => model.toJson(),
            ),
        _propertyCollectionPath =
            '/$FIREBASE_COLLECTION_SHARED_NOTES/$pairId/$FIREBASE_COLLECTION_PROPERTIES',
        _categoryCollectionPath =
            '/$FIREBASE_COLLECTION_SHARED_NOTES/$pairId/$FIREBASE_COLLECTION_CATEGORIES';

  late final CollectionReference<IncomeRecordModel> _incomeCollectionRef;
  late final CollectionReference<ExpenseRecordModel> _expenseCollectionRef;
  late final CollectionReference<TransferRecordModel> _transferCollectionRef;
  final String _categoryCollectionPath;
  final String _propertyCollectionPath;

  @override
  Future<Either<Failure, Unit>> deleteById(
    String id,
    RecordType type,
  ) async {
    switch (type) {
      case RecordType.income:
        await _incomeCollectionRef.doc(id).delete();
        break;
      case RecordType.expense:
        await _expenseCollectionRef.doc(id).delete();
        break;
      case RecordType.transfer:
        await _transferCollectionRef.doc(id).delete();
        break;
    }
    return Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> register(Record value,) async {
    switch (value.type) {
      case RecordType.income:
        await _incomeCollectionRef.doc(value.id).set(
          IncomeRecordModel.fromIncomeRecord(
            record: value as IncomeRecord,
                categoryCollectionPath: _categoryCollectionPath,
                propertyCollectionPath: _propertyCollectionPath,
              ),
        );
        break;
      case RecordType.expense:
        await _expenseCollectionRef.doc(value.id).set(
          ExpenseRecordModel.fromExpenseRecord(
                categoryCollectionPath: _categoryCollectionPath,
                propertyCollectionPath: _propertyCollectionPath,
                record: value as ExpenseRecord,
              ),
        );
        break;
      case RecordType.transfer:
        await _transferCollectionRef.doc(value.id).set(
          TransferRecordModel.fromTransferRecord(
            record: value as TransferRecord,
                propertyCollectionPath: _propertyCollectionPath,
              ),
        );
        break;
    }

    return Right(unit);
  }

  @override
  Future<Either<Failure, Record>> retrieveById(String id,
      RecordType type,) async {
    DocumentSnapshot<dynamic> snapshot;
    switch (type) {
      case RecordType.income:
        snapshot = await _incomeCollectionRef.doc(id).get();
        break;
      case RecordType.expense:
        snapshot = await _expenseCollectionRef.doc(id).get();
        break;
      case RecordType.transfer:
        snapshot = await _transferCollectionRef.doc(id).get();
        break;
    }

    if (!snapshot.exists) {
      return Left(RepositoryFailure());
    }

    return Right(snapshot.data()!);
  }

  @override
  Future<Either<Failure, List<Record>>> retrieveRecordsOf(DateTime begin,
      DateTime end,) async {
    assert(
    begin.isBefore(end),
    '$begin is after or at the same moment as $end',
    );

    final List<Record> incomeModels = await _incomeCollectionRef
        .where('date', isGreaterThanOrEqualTo: begin)
        .where('date', isLessThan: end)
        .get()
        .then(
          (QuerySnapshot<IncomeRecordModel> querySnapshot) => List.of(
        querySnapshot.docs.map(
              (queryDocumentSnapshot) => queryDocumentSnapshot.data(),
        ),
      ),
    );
    final List<Record> expenseModels = await _expenseCollectionRef
        .where('date', isGreaterThanOrEqualTo: begin)
        .where('date', isLessThan: end)
        .get()
        .then(
          (QuerySnapshot<ExpenseRecordModel> querySnapshot) => List.of(
        querySnapshot.docs.map(
              (queryDocumentSnapshot) => queryDocumentSnapshot.data(),
        ),
      ),
    );
    final List<Record> transferModels = await _transferCollectionRef
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

    return Right(List.from([
      ...incomeModels,
      ...expenseModels,
      ...transferModels,
    ]));
  }
}
