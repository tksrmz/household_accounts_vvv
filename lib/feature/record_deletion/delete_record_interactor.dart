import 'package:dartz/dartz.dart';
import 'package:household_accounts/feature/record_deletion/delete_record_use_case.dart';
import 'package:household_accounts/feature/repository/record_repository.dart';

import '../../util/type/exception_or.dart';

class DeleteRecordInteractorNew implements DeleteRecordUseCaseNew {
  final RecordRepositoryNew _repository;

  DeleteRecordInteractorNew(this._repository);

  @override
  Future<ExceptionOr<Unit>> call(DeleteRecordInputNew input) =>
      _repository.deleteById(input.id, input.type);
}
