import 'package:dartz/dartz.dart';
import 'package:household_accounts/features/input-page/domain/repositories/record_repository.dart';
import 'package:household_accounts/features/record-calendar-page/domain/use-cases/delete_record.dart';
import 'package:household_accounts/util/failures/failure.dart';

class DeleteRecordInteractor implements DeleteRecordUseCase {
  final RecordRepository _repository;

  DeleteRecordInteractor(this._repository);

  @override
  Future<Either<Failure, Unit>> handle(DeleteRecordInput input) =>
      _repository.deleteById(input.id);
}
