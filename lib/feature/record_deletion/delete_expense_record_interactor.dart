import 'package:dartz/dartz.dart';

import '../../util/type/exception_or.dart';
import 'delete_expense_record_use_case.dart';

class DeleteExpenseRecordInteractor implements DeleteExpenseRecordUseCase {
  @override
  Future<ExceptionOr<Unit>> call(DeleteExpenseRecordInput input) {
    final repository = input.repository;
    return repository.deleteById(
      repoId: input.uid,
      id: input.recordId,
    );
  }
}
