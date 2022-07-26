import 'package:dartz/dartz.dart';
import 'package:household_accounts/features/input-page/domain/repositories/record_repository.dart';
import 'package:household_accounts/features/record-calendar-page/domain/use-cases/delete_record.dart';
import 'package:household_accounts/util/failures/failure.dart';

class DeleteRecordInteractorNew implements DeleteRecordUseCaseNew {
  final RecordRepositoryNew _repository;

  DeleteRecordInteractorNew(this._repository);

  @override
  Future<Either<Failure, Unit>> handle(DeleteRecordInputNew input) =>
      _repository.deleteById(input.id, input.type);
}
