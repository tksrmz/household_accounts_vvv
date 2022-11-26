import 'package:dartz/dartz.dart';

import '../../util/type/exception_or.dart';
import 'delete_income_record_use_case.dart';

@deprecated
class DeleteIncomeRecordInteractor implements DeleteIncomeRecordUseCase {
  @override
  Future<ExceptionOr<Unit>> call(DeleteIncomeRecordInput input) {
    final repository = input.repository;
    return repository.deleteById(
      repoId: input.uid,
      id: input.recordId,
    );
  }
}
