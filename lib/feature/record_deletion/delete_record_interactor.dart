import 'package:dartz/dartz.dart';
import 'package:household_accounts/feature/repository/record_repository.dart';
import 'package:household_accounts/feature/record_deletion/delete_record_use_case.dart';
import 'package:household_accounts/util/type/failure.dart';

class DeleteRecordInteractorNew implements DeleteRecordUseCaseNew {
  final RecordRepositoryNew _repository;

  DeleteRecordInteractorNew(this._repository);

  @override
  Future<Either<Failure, Unit>> handle(DeleteRecordInputNew input) =>
      _repository.deleteById(input.id, input.type);
}
