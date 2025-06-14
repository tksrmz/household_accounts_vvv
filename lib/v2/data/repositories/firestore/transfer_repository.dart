import 'package:dartz/dartz.dart';
import 'package:household_accounts/v2/data/services/firestore/personal/personal_transfer_record_service.dart';
import 'package:household_accounts/v2/data/models/transfer_record_model.dart' as data;

import '../../../domain/models/property.dart';
import '../../../domain/models/transfer_record.dart';
import '../../../domain/models/vo/record_amount.dart';
import '../../../domain/models/vo/record_date.dart';
import '../../../domain/models/vo/record_id.dart';
import '../../../domain/models/vo/record_note.dart';
import '../../../domain/models/vo/user_id.dart';
import '../../../domain/repositories/transfer_repository.dart';

class FirestoreTransferRepository implements TransferRepository {
  const FirestoreTransferRepository(
    this._personalTransferRecordService,
    this._uid,
  );

  final PersonalTransferRecordService _personalTransferRecordService;
  final UserIdVo _uid;

  @override
  Future<Either<Exception, List<TransferRecordModel>>> fetchMonthly(DateTime date) async {
    final result = await _personalTransferRecordService.fetchPersonalTransfers(
      _uid,
      date.year,
      date.month,
    );
    return result.map((transferModels) => 
      transferModels.map((model) => TransferRecordModel(
        id: RecordIdVo(model.id),
        recordDate: RecordDateVo(model.date),
        amount: RecordAmountVo(model.amount),
        note: RecordNoteVo(model.note),
        source: PropertyModel.deleted, // Placeholder - would need proper conversion
        destination: PropertyModel.deleted, // Placeholder - would need proper conversion
        hasCheckedOut: model.hasCheckedOut,
      )).toList(growable: false)
    );
  }

  @override
  Future<Either<Exception, Unit>> add(TransferRecordModel record) async {
    final model = data.TransferRecordModel(
      id: record.id.value,
      date: record.recordDate.value,
      amount: record.amount.value,
      note: record.note.value,
      hasCheckedOut: record.hasCheckedOut,
      createdAt: DateTime.now(),
      fromProperty: {'ref': '/personalNotes/${_uid.value}/properties/${record.source.id.value}'},
      toProperty: {'ref': '/personalNotes/${_uid.value}/properties/${record.destination.id.value}'},
    );
    return _personalTransferRecordService.addPersonalTransfer(_uid, model);
  }

  @override
  Future<Either<Exception, Unit>> delete(RecordIdVo id) async {
    return _personalTransferRecordService.deletePersonalTransfer(_uid, id.value);
  }
}