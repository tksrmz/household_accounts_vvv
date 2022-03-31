import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:household_accounts/constants/firebase/firebase_constant.dart';
import 'package:household_accounts/features/input-page/data/models/record_model.dart';
import 'package:household_accounts/features/input-page/domain/entities/record.dart';
import 'package:household_accounts/features/input-page/domain/repositories/record_repository.dart';
import 'package:household_accounts/util/failures/failure.dart';

class FirebaseRecordRepository implements RecordRepositoryNew {
  FirebaseRecordRepository.of(this.uid)
      : _incomeCollectionRef = FirebaseFirestore.instance
            .collection(
                '/$FIREBASE_COLLECTION_PERSONAL_NOTES/$uid/$FIREBASE_COLLECTION_INCOMES')
            .withConverter(
              fromFirestore: (snapshot, _) => IncomeRecordModel.fromIdAndJson(
                uid: uid,
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
                uid: uid,
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
                uid: uid,
                id: snapshot.id,
                json: snapshot.data()!,
              ),
              toFirestore: (model, _) => model.toJson(),
            );

  late final CollectionReference<IncomeRecordModel> _incomeCollectionRef;
  late final CollectionReference<ExpenseRecordModel> _expenseCollectionRef;
  late final CollectionReference<TransferRecordModel> _transferCollectionRef;
  final String uid;

  @override
  Future<Either<Failure, Unit>> deleteById(
    String id,
    RecordType type,
  ) {
    // TODO: implement deleteById
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> register(
    Record value,
  ) async {
    switch (value.type) {
      case RecordType.income:
        await _incomeCollectionRef.doc(value.id).set(
              IncomeRecordModel.fromIncomeRecord(
                uid: uid,
                record: value as IncomeRecord,
              ),
            );
        break;
      case RecordType.expense:
        await _expenseCollectionRef.doc(value.id).set(
              ExpenseRecordModel.fromExpenseRecord(
                record: value as ExpenseRecord,
                uid: uid,
              ),
            );
        break;
      case RecordType.transfer:
        await _transferCollectionRef.doc(value.id).set(
              TransferRecordModel.fromTransferRecord(
                record: value as TransferRecord,
                uid: uid,
              ),
            );
        break;
    }

    return Right(unit);
  }

  @override
  Future<Either<Failure, Record>> retrieveById(
    String id,
    RecordType type,
  ) {
    // TODO: implement retrieveById
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Record>>> retrieveRecordsOf(
    DateTime begin,
    DateTime end,
  ) {
    // TODO: implement retrieveRecordsOf
    throw UnimplementedError();
  }
}
