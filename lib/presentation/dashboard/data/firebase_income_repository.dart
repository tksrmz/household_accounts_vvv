import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:household_accounts/entity/income.dart';

import '../repository/income_repository.dart';

class FirebaseIncomeRepository implements IncomeRepository {
  const FirebaseIncomeRepository(this.db);

  final FirebaseFirestore db;

  @override
  Future<List<Income>> fetchMonthly(DateTime date) async {
    assert(date == DateTime(date.year, date.month), 'dateの値が月初の0時ではない');

    final querySnapshot = await db
        .collection('hoge')
        .where('date', isGreaterThanOrEqualTo: date)
        .where('date', isLessThan: DateTime(date.year, date.month + 1))
        .get();
    return querySnapshot.docs
        .map((doc) => Income(doc.data()['amount']!))
        .toList(growable: false);
  }
}
