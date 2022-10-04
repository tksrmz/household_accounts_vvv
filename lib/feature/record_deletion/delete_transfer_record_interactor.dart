import 'package:dartz/dartz.dart';

import '../../util/type/exception_or.dart';
import 'delete_transfer_record_use_case.dart';

class DeleteTransferRecordInteractor implements DeleteTransferRecordUseCase {
  @override
  Future<ExceptionOr<Unit>> call(DeleteTransferRecordInput input) {
    final repository = input.repository;
    return repository.deleteById(
      repoId: input.uid,
      id: input.recordId,
    );
  }
}
