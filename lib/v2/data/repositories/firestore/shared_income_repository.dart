import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:household_accounts/v2/data/services/firestore/shared/shared_record_service.dart';
import 'package:household_accounts/v2/data/services/firestore/profile/private_profile_service.dart';

import '../../../domain/models/income_record.dart';
import '../../../domain/models/vo/income.dart';
import '../../../domain/models/vo/record_id.dart';
import '../../../domain/models/vo/user_id.dart';
import '../../../domain/repositories/income_repository.dart';
import 'private_profile_util.dart';

class FirestoreSharedIncomeRepository implements IncomeRepository {
  const FirestoreSharedIncomeRepository(
    this._sharedRecordService,
    this._privateProfileService,
    this._userId,
  );

  final SharedRecordService _sharedRecordService;
  final PrivateProfileService _privateProfileService;
  final UserIdVo _userId;

  @override
  Future<Either<Exception, List<IncomeVo>>> fetchMonthly(DateTime date) async {
    IncomeVo createIncomeVo(Map<String, dynamic> doc) =>
        IncomeVo(doc['amount']!);
    List<IncomeVo> convertToIncomeVoList(
      List<Map<String, dynamic>> incomeList,
    ) => incomeList.map(createIncomeVo).toList(growable: false);

    Task<Either<Exception, List<IncomeVo>>> createTask(
      DocumentReference<SharedNoteRef> ref,
    ) => Task(
      () => _sharedRecordService.fetchIncomesByDate(ref, date.year, date.month),
    ).map((either) => either.map<List<IncomeVo>>(convertToIncomeVoList));

    final Task<Either<Exception, List<IncomeVo>>> task =
        Task(() => _privateProfileService.fetch(_userId))
            .map(getSharedNoteRef)
            .bind(
              (either) => either.fold((_) => Task.value(Right([])), createTask),
            );

    return await task.run();
  }

  @override
  Future<Either<Exception, Unit>> add(IncomeRecordModel record) async {
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
