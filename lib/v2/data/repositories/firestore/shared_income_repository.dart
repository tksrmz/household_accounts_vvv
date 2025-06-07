import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:household_accounts/v2/data/services/firestore_service.dart';

import '../../../domain/models/income_record.dart';
import '../../../domain/models/vo/income.dart';
import '../../../domain/models/vo/record_id.dart';
import '../../../domain/models/vo/user_id.dart';
import '../../../domain/repositories/income_repository.dart';
import 'private_profile_util.dart';

class FirestoreSharedIncomeRepository implements IncomeRepository {
  const FirestoreSharedIncomeRepository(
    this._firestoreService,
    this._userId,
  );

  final FirestoreService _firestoreService;
  final UserIdVo _userId;

  @override
  Future<Either<Exception, List<IncomeVo>>> fetchMonthly(DateTime date) async {
    final createIncomeVo =
        (Map<String, dynamic> doc) => IncomeVo(doc['amount']!);
    final convertToIncomeVoList = (List<Map<String, dynamic>> incomeList) =>
        incomeList.map(createIncomeVo).toList(growable: false);

    final createTask = (DocumentReference<SharedNoteRef> ref) => Task(
          () => _firestoreService.fetchMonthlySharedIncomesFrom(
            ref,
            date.year,
            date.month,
          ),
        ).map(
          (either) => either.map<List<IncomeVo>>(convertToIncomeVoList),
        );

    final Task<Either<Exception, List<IncomeVo>>> task =
        Task(() => _firestoreService.fetchPrivateProfileOf(_userId))
            .map(getSharedNoteRef)
            .bind(
              (either) => either.fold((_) => Task.value(Right([])), createTask),
            );

    return await task.run();
  }

  @override
  Future<Either<Exception, Unit>> add(IncomeRecordVo record) async {
    // TODO: Implement shared income record addition
    // This would require accessing the shared note reference and adding the record there
    return Left(Exception('Shared income record addition not yet implemented'));
  }

  @override
  Future<Either<Exception, Unit>> delete(RecordIdVo id) async {
    // TODO: Implement shared income record deletion
    // This would require accessing the shared note reference and deleting the record
    return Left(Exception('Shared income record deletion not yet implemented'));
  }
}
