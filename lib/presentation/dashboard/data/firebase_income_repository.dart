import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:household_accounts/entity/income.dart';
import 'package:household_accounts/util/extension/collection_reference.dart';

import '../repository/income_repository.dart';

class FirebaseIncomeRepository implements IncomeRepository {
  const FirebaseIncomeRepository(
    this.db,
    this._collectionPath,
  );

  final FirebaseFirestore db;
  final String _collectionPath;

  @override
  Future<List<Income>> fetchMonthly(DateTime date) async {
    final querySnapshot = await db
        .collection(_collectionPath)
        .whereInThisMonth('date', date)
        .get();
    return querySnapshot.docs
        .map((doc) => Income(doc.data()['amount']!))
        .toList(growable: false);
  }
}
