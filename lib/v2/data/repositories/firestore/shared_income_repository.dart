import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:household_accounts/v2/data/services/firestore_service.dart';

import '../../../domain/models/vo/income.dart';
import '../../../domain/models/vo/user_id.dart';
import '../../../domain/repositories/income_repository.dart';

class FirestoreSharedIncomeRepository implements IncomeRepository {
  const FirestoreSharedIncomeRepository(
    this._firestoreService,
    this._userId,
  );

  final FirestoreService _firestoreService;
  final UserIdVo _userId;

  @override
  Future<Either<Exception, List<IncomeVo>>> fetchMonthly(DateTime date) async {
    final privateProfileDocSnapshot =
        await _firestoreService.fetchPrivateProfileOf(_userId);

    if (!privateProfileDocSnapshot.exists ||
        privateProfileDocSnapshot.data() == null) {
      return Right([]);
    }

    final sharedNote = privateProfileDocSnapshot.data()!.sharedNote;
    if (sharedNote == null) {
      return Right([]);
    }
    if (!sharedNote.containsKey('ref')) {
      return Right([]);
    }

    final sharedNoteDocRef =
        sharedNote['ref']! as DocumentReference<Map<String, dynamic>>;

    final result = await _firestoreService.fetchMonthlySharedIncomesFrom(
      sharedNoteDocRef,
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
