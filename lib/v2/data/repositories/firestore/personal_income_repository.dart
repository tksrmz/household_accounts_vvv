import 'package:household_accounts/v2/data/services/firestore_service.dart';
import 'package:household_accounts/v2/domain/models/vo/income.dart';

import '../../../domain/models/vo/user_id.dart';
import '../../../domain/repositories/income_repository.dart';

class FirestorePersonalIncomeRepository implements IncomeRepository {
  const FirestorePersonalIncomeRepository(
    this._firestoreService,
    this._uid,
  );

  final FirestoreService _firestoreService;
  final UserIdVo _uid;

  @override
  Future<List<IncomeVo>> fetchMonthly(DateTime date) async {
    final incomeList = await _firestoreService.fetchMonthlyPersonalIncomesOf(
      _uid,
      date.year,
      date.month,
    );
    return incomeList
        .map((doc) => IncomeVo(doc['amount']!))
        .toList(growable: false);
  }
}
