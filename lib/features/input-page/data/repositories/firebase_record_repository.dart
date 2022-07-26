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
        _incomeCategoryCollectionPath = '',
        _expenseCategoryCollectionPath = '';

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
        _incomeCategoryCollectionPath =
            '/$FIREBASE_COLLECTION_PERSONAL_NOTES/$uid/$FIREBASE_COLLECTION_INCOME_CATEGORIES',
        _expenseCategoryCollectionPath =
            '/$FIREBASE_COLLECTION_PERSONAL_NOTES/$uid/$FIREBASE_COLLECTION_EXPENSE_CATEGORIES';

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
        _incomeCategoryCollectionPath =
            '/$FIREBASE_COLLECTION_PERSONAL_NOTES/$pairId/$FIREBASE_COLLECTION_INCOME_CATEGORIES',
        _expenseCategoryCollectionPath =
            '/$FIREBASE_COLLECTION_PERSONAL_NOTES/$pairId/$FIREBASE_COLLECTION_EXPENSE_CATEGORIES';

  late final CollectionReference<IncomeRecordModel> _incomeCollectionRef;
  late final CollectionReference<ExpenseRecordModel> _expenseCollectionRef;
  late final CollectionReference<TransferRecordModel> _transferCollectionRef;
  final String _incomeCategoryCollectionPath;
  final String _expenseCategoryCollectionPath;
  final String _propertyCollectionPath;

  @override
  Future<Either<Failure, Unit>> deleteById(
    String id,
    RecordType type,
  ) async {
    TransactionHandler handler;
    switch (type) {
      case RecordType.income:
        handler = (Transaction transaction) async {
          final recordDocument = _incomeCollectionRef.doc(id);
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
        break;
      case RecordType.expense:
        handler = (Transaction transaction) async {
          final recordDocument = _expenseCollectionRef.doc(id);
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
        break;
      case RecordType.transfer:
        handler = (Transaction transaction) async {
          final recordDocument = _transferCollectionRef.doc(id);
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
        break;
    }

    await FirebaseFirestore.instance.runTransaction(handler);

    return Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> register(
    Record value,
  ) async {
    final batch = FirebaseFirestore.instance.batch();
    switch (value.type) {
      case RecordType.income:
        final income = value as IncomeRecord;
        batch.update(
          FirebaseFirestore.instance
              .doc('$_propertyCollectionPath/${income.propertyId}'),
          {
            'amount': FieldValue.increment(income.amount),
          },
        );
        batch.set(
          _incomeCollectionRef.doc(value.id),
          IncomeRecordModel.fromIncomeRecord(
            record: income,
            categoryCollectionPath: _incomeCategoryCollectionPath,
            propertyCollectionPath: _propertyCollectionPath,
          ),
        );
        break;
      case RecordType.expense:
        final expense = value as ExpenseRecord;
        batch.update(
          FirebaseFirestore.instance
              .doc('$_propertyCollectionPath/${expense.propertyId}'),
          {
            'amount': FieldValue.increment(-expense.amount),
          },
        );
        batch.set(
          _expenseCollectionRef.doc(value.id),
          ExpenseRecordModel.fromExpenseRecord(
            record: expense,
            categoryCollectionPath: _expenseCategoryCollectionPath,
            propertyCollectionPath: _propertyCollectionPath,
          ),
        );
        break;
      case RecordType.transfer:
        final transfer = value as TransferRecord;
        batch.update(
          FirebaseFirestore.instance
              .doc('$_propertyCollectionPath/${transfer.srcPropertyId}'),
          {
            'amount': FieldValue.increment(-transfer.amount),
          },
        );
        batch.update(
          FirebaseFirestore.instance
              .doc('$_propertyCollectionPath/${transfer.destPropertyId}'),
          {
            'amount': FieldValue.increment(transfer.amount),
          },
        );
        batch.set(
          _transferCollectionRef.doc(value.id),
          TransferRecordModel.fromTransferRecord(
            record: transfer,
            propertyCollectionPath: _propertyCollectionPath,
          ),
        );
        break;
    }

    await batch.commit();

    return Right(unit);
  }

  @override
  Future<Either<Failure, Record>> retrieveById(
    String id,
    RecordType type,
  ) async {
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
  Future<Either<Failure, List<Record>>> retrieveRecordsOf(
    DateTime begin,
    DateTime end,
  ) async {
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
