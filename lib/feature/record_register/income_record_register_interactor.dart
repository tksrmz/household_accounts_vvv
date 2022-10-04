import 'package:dartz/dartz.dart';

import '../../entity/record_entity.dart';
import '../../util/type/exception_or.dart';
import '../../util/uuid/uuid.dart';
import 'income_record_register_use_case.dart';

class AddIncomeRecordInteractor implements AddIncomeRecordUseCase {
  @override
  Future<ExceptionOr<Unit>> call(
    AddIncomeRecordInput input,
  ) {
    final repository = input.repository;

    final record = IncomeRecord(
      UUID.generate(),
      input.recordDate,
      input.amount,
      input.note,
      input.categoryId,
      input.propertyId,
    );
    return repository.register(
      repoId: input.uid,
      value: record,
    );
  }
}
