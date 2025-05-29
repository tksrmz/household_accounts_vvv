import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:household_accounts/v2/data/services/firestore_service.dart';

import '../../../domain/models/vo/expense.dart';
import '../../../domain/models/vo/user_id.dart';
import '../../../domain/repositories/expense_repository.dart';

class FirestoreSharedExpenseRepository implements ExpenseRepository {
  const FirestoreSharedExpenseRepository(
    this._firestoreService,
    this._userId,
  );

  final FirestoreService _firestoreService;
  final UserIdVo _userId;

  @override
  Future<Either<Exception, List<ExpenseVo>>> fetchMonthly(DateTime date) async {
    final privateProfileDocSnapshot =
        await _firestoreService.fetchPrivateProfileOf(_userId);

    if (!privateProfileDocSnapshot.exists ||
        privateProfileDocSnapshot.data() == null) {
      return Right([]);
    }

    final sharedNote = privateProfileDocSnapshot.data()!.sharedNote;
    if (sharedNote == null) {
      return Right([]);
    }
    if (!sharedNote.containsKey('ref')) {
      return Right([]);
    }

    final sharedNoteDocRef =
        sharedNote['ref']! as DocumentReference<Map<String, dynamic>>;

    final result = await _firestoreService.fetchMonthlySharedExpensesFrom(
      sharedNoteDocRef,
      date.year,
      date.month,
    );

    final createExpenseVo =
        (Map<String, dynamic> doc) => ExpenseVo(doc['amount']!);
    final convertToExpenseVoList = (List<Map<String, dynamic>> expenseList) =>
        expenseList.map(createExpenseVo).toList(growable: false);
    return result.map(convertToExpenseVoList);
  }
}
