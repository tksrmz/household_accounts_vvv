import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:household_accounts/v2/data/repositories/firestore/private_profile_util.dart';
import 'package:household_accounts/v2/data/services/firestore_service.dart';

import '../../../domain/models/expense_record.dart';
import '../../../domain/models/vo/expense.dart';
import '../../../domain/models/vo/record_id.dart';
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
    final createExpenseVo =
        (Map<String, dynamic> doc) => ExpenseVo(doc['amount']!);
    final convertToExpenseVoList = (List<Map<String, dynamic>> expenseList) =>
        expenseList.map(createExpenseVo).toList(growable: false);

    final createTask = (DocumentReference<SharedNoteRef> ref) => Task(
          () => _firestoreService.fetchMonthlySharedExpensesFrom(
            ref,
            date.year,
            date.month,
          ),
        ).map(
          (either) => either.map<List<ExpenseVo>>(convertToExpenseVoList),
        );

    final Task<Either<Exception, List<ExpenseVo>>> task =
        Task(() => _firestoreService.fetchPrivateProfileOf(_userId))
            .map(getSharedNoteRef)
            .bind(
              (either) => either.fold((_) => Task.value(Right([])), createTask),
            );

    return await task.run();
  }

  @override
  Future<Either<Exception, Unit>> add(ExpenseRecordVo record) async {
    // TODO: Implement shared expense record addition
    // This would require accessing the shared note reference and adding the record there
    return Left(Exception('Shared expense record addition not yet implemented'));
  }

  @override
  Future<Either<Exception, Unit>> delete(RecordIdVo id) async {
    // TODO: Implement shared expense record deletion
    // This would require accessing the shared note reference and deleting the record
    return Left(Exception('Shared expense record deletion not yet implemented'));
  }
}
