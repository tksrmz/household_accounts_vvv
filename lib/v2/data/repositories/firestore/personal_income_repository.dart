import 'package:dartz/dartz.dart';
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
  Future<Either<Exception, List<IncomeVo>>> fetchMonthly(DateTime date) async {
    final result = await _firestoreService.fetchMonthlyPersonalIncomesOf(
      _uid,
      date.year,
      date.month,
    );
    final createIncomeVo =
        (Map<String, dynamic> doc) => IncomeVo(doc['amount']!);
    final convertToIncomeVoList = (List<Map<String, dynamic>> incomeList) =>
        incomeList.map(createIncomeVo).toList(growable: false);
    return result.map(convertToIncomeVoList);
  }
}
