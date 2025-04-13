import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:household_accounts/entity/income.dart';
import 'package:household_accounts/util/extension/date_time.dart';

import '../../../data/firebase/util/path_builder.dart';
import '../repository/income_repository.dart';

class FirebaseIncomeRepository implements IncomeRepository {
  const FirebaseIncomeRepository(this.db);

  final FirebaseFirestore db;

  @override
  Future<List<Income>> fetchMonthly(DateTime date) async {
    final firstDayOfMonth = date.toFirstDayOfMonth();

    final querySnapshot = await db
        .collection(
          getPersonalIncomeRecordCollectionPath(
            'fmVfCNkA2wGfJx69LRFhl3ird9EB',
          ),
        )
        .where('date', isGreaterThanOrEqualTo: firstDayOfMonth)
        .where('date', isLessThan: firstDayOfMonth.nextMonth())
        .get();
    return querySnapshot.docs
        .map((doc) => Income(doc.data()['amount']!))
        .toList(growable: false);
  }
}
