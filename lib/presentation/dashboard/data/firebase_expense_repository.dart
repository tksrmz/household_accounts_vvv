import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:household_accounts/util/extension/date_time.dart';

import '../../../entity/expense.dart';
import '../repository/expense_repository.dart';

class FirebaseExpenseRepository implements ExpenseRepository {
  const FirebaseExpenseRepository(this.db);

  final FirebaseFirestore db;

  @override
  Future<List<Expense>> fetchMonthly(DateTime date) async {
    final firstDayOfMonth = date.toFirstDayOfMonth();

    final querySnapshot = await db
        .collection('hoge')
        .where('date', isGreaterThanOrEqualTo: firstDayOfMonth)
        .where('date', isLessThan: firstDayOfMonth.nextMonth())
        .get();
    return querySnapshot.docs
        .map((doc) => Expense(doc.data()['amount']!))
        .toList(growable: false);
  }
}
