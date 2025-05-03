import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:household_accounts/util/extension/collection_reference.dart';

import '../../domain/models/vo/expense.dart';
import '../../domain/repositories/expense_repository.dart';

class FirebaseExpenseRepository implements ExpenseRepository {
  const FirebaseExpenseRepository(
    this.db,
    this._collectionPath,
  );

  final FirebaseFirestore db;
  final String _collectionPath;

  @override
  Future<List<ExpenseVo>> fetchMonthly(DateTime date) async {
    final querySnapshot = await db
        .collection(_collectionPath)
        .whereInThisMonth('date', date)
        .get();
    return querySnapshot.docs
        .map((doc) => ExpenseVo(doc.data()['amount']!))
        .toList(growable: false);
  }
}
