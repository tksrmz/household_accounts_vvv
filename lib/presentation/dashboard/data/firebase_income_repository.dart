import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:household_accounts/entity/income.dart';

import '../repository/income_repository.dart';

class FirebaseIncomeRepository implements IncomeRepository {
  const FirebaseIncomeRepository(this.db);

  final FirebaseFirestore db;

  @override
  Future<List<Income>> fetchMonthly(DateTime date) {
    return Future.value([Income(100)]);
  }
}
