import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:household_accounts/util/extension/collection_reference.dart';
import 'package:household_accounts/v2/domain/models/vo/income.dart';

import '../../../domain/models/vo/user_id.dart';
import '../../../domain/repositories/income_repository.dart';

class FirestorePersonalIncomeRepository implements IncomeRepository {
  const FirestorePersonalIncomeRepository(
    this._db,
    this._uid,
  );

  final FirebaseFirestore _db;
  final UserIdVo _uid;

  @override
  Future<List<IncomeVo>> fetchMonthly(DateTime date) async {
    final querySnapshot = await _db
        .collection('/personalNotes/${_uid.value}/incomes')
        .whereInThisMonth('date', date)
        .get();
    return querySnapshot.docs
        .map((doc) => IncomeVo(doc.data()['amount']!))
        .toList(growable: false);
  }
}
