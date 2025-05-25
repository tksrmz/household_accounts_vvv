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
  Future<List<ExpenseVo>> fetchMonthly(DateTime date) async {
    final expenseList = await _firestoreService.fetchAllPersonalExpensesOf(
      _uid,
      date.year,
      date.month,
    );
    return expenseList
        .map((doc) => ExpenseVo(doc['amount']!))
        .toList(growable: false);
  }
}
