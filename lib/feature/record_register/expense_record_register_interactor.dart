import 'package:dartz/dartz.dart';

import '../../entity/record_entity.dart';
import '../../util/type/exception_or.dart';
import '../../util/uuid/uuid.dart';
import 'expense_record_register_use_case.dart';

@deprecated
class AddExpenseRecordInteractor implements AddExpenseRecordUseCase {
  @override
  Future<ExceptionOr<Unit>> call(AddExpenseRecordInput input,) {
    final repository = input.repository;

    final record = ExpenseRecord(
      UUID.generate(),
      input.recordDate,
      input.amount,
      input.note,
      input.category,
      input.property,
    );
    return repository.register(
      repoId: input.uid,
      value: record,
    );
  }
}
