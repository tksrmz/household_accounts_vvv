import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:household_accounts/util/extension/collection_reference.dart';

import '../../../domain/models/vo/expense.dart';
import '../../../domain/models/vo/user_id.dart';
import '../../../domain/repositories/expense_repository.dart';
import '../../models/privateProfile.dart';

class FirestoreSharedExpenseRepository implements ExpenseRepository {
  const FirestoreSharedExpenseRepository(
    this._db,
    this._userId,
  );

  final FirebaseFirestore _db;
  final UserIdVo _userId;

  @override
  Future<List<ExpenseVo>> fetchMonthly(DateTime date) async {
    final privateProfileDocSnapshot = await _db
        .doc('/privateProfiles/${_userId.value}')
        .withConverter(
          fromFirestore: (snapshot, _) =>
              PrivateProfile.fromJson(snapshot.data()!),
          toFirestore: (data, _) => data.toJson(),
        )
        .get();

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
