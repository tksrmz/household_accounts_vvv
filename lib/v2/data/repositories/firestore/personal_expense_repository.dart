import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:household_accounts/util/extension/collection_reference.dart';

import '../../../domain/models/vo/expense.dart';
import '../../../domain/models/vo/user_id.dart';
import '../../../domain/repositories/expense_repository.dart';

class FirestorePersonalExpenseRepository implements ExpenseRepository {
  const FirestorePersonalExpenseRepository(
    this._db,
    this._uid,
  );

  final FirebaseFirestore _db;
  final UserIdVo _uid;

  @override
  Future<List<ExpenseVo>> fetchMonthly(DateTime date) async {
    final querySnapshot = await _db
        .collection('/personalNotes/${_uid.value}/expenses')
        .whereInThisMonth('date', date)
        .get();
    return querySnapshot.docs
        .map((doc) => ExpenseVo(doc.data()['amount']!))
        .toList(growable: false);
  }
}
