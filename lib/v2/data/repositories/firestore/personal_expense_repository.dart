import 'package:dartz/dartz.dart';
import 'package:household_accounts/v2/data/services/firestore_service.dart';

import '../../../domain/models/vo/expense.dart';
import '../../../domain/models/vo/user_id.dart';
import '../../../domain/repositories/expense_repository.dart';

class FirestorePersonalExpenseRepository implements ExpenseRepository {
  const FirestorePersonalExpenseRepository(
    this._firestoreService,
    this._uid,
  );

  final FirestoreService _firestoreService;
  final UserIdVo _uid;

  @override
  Future<Either<Exception, List<ExpenseVo>>> fetchMonthly(DateTime date) async {
    final result = await _firestoreService.fetchAllPersonalExpensesOf(
      _uid,
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
