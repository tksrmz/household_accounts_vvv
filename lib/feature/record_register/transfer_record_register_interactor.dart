import 'package:dartz/dartz.dart';

import '../../entity/record_entity.dart';
import '../../util/type/exception_or.dart';
import '../../util/uuid/uuid.dart';
import 'transfer_record_register_use_case.dart';

@deprecated
class AddTransferRecordInteractor implements AddTransferRecordUseCase {
  @override
  Future<ExceptionOr<Unit>> call(
    AddTransferRecordInput input,
  ) {
    final repository = input.repository;

    final record = TransferRecord(
      UUID.generate(),
      input.recordDate,
      input.amount,
      input.note,
      input.source,
      input.destination,
    );
    return repository.register(
      repoId: input.uid,
      value: record,
    );
  }
}
