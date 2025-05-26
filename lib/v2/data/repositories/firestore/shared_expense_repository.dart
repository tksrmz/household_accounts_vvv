import 'package:cloud_firestore/cloud_firestore.dart';
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
  Future<List<ExpenseVo>> fetchMonthly(DateTime date) async {
    final privateProfileDocSnapshot = await _firestoreService.fetchPrivateProfileOf(_userId);

    if (!privateProfileDocSnapshot.exists ||
        privateProfileDocSnapshot.data() == null) {
      return [];
    }

    final sharedNote = privateProfileDocSnapshot.data()!.sharedNote;
    if (sharedNote == null) {
      return [];
    }
    if (!sharedNote.containsKey('ref')) {
      return [];
    }

    final sharedNoteDocRef =
        sharedNote['ref']! as DocumentReference<Map<String, dynamic>>;

    final querySnapshot = await sharedNoteDocRef
        .collection('expenses')
        .whereInThisMonth('date', date)
        .get();
    return querySnapshot.docs
        .map((doc) => ExpenseVo(doc.data()['amount']!))
        .toList(growable: false);
  }
}
