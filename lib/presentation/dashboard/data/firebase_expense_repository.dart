import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:household_accounts/util/extension/collection_reference.dart';

import '../../../data/firebase/util/path_builder.dart';
import '../../../entity/expense.dart';
import '../repository/expense_repository.dart';

class FirebaseExpenseRepository implements ExpenseRepository {
  const FirebaseExpenseRepository(
    this.db,
    this._personalNoteId,
  );

  final FirebaseFirestore db;
  final String _personalNoteId;

  String get _expenseRecordCollectionPath =>
      getPersonalExpenseRecordCollectionPath(_personalNoteId);

  @override
  Future<List<Expense>> fetchMonthly(DateTime date) async {
    final querySnapshot = await db
        .collection(_expenseRecordCollectionPath)
        .whereInThisMonth('date', date)
        .get();
    return querySnapshot.docs
        .map((doc) => Expense(doc.data()['amount']!))
        .toList(growable: false);
  }
}
