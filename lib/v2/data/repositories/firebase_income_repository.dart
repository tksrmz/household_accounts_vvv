import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:household_accounts/util/extension/collection_reference.dart';
import 'package:household_accounts/v2/domain/models/vo/income.dart';

import '../../domain/repositories/income_repository.dart';

class FirebaseIncomeRepository implements IncomeRepository {
  const FirebaseIncomeRepository(
    this._db,
    this._collectionPath,
  );

  final FirebaseFirestore _db;
  final String _collectionPath;

  @override
  Future<List<IncomeVo>> fetchMonthly(DateTime date) async {
    final querySnapshot = await _db
        .collection(_collectionPath)
        .whereInThisMonth('date', date)
        .get();
    return querySnapshot.docs
        .map((doc) => IncomeVo(doc.data()['amount']!))
        .toList(growable: false);
  }
}
