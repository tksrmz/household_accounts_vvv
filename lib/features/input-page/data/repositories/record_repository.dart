import 'package:dartz/dartz.dart';
import 'package:household_accounts/features/input-page/domain/entities/record.dart';
import 'package:household_accounts/features/input-page/domain/repositories/record_repository.dart';
import 'package:household_accounts/util/failures/failure.dart';

class InMemoryRecordRepository implements RecordRepositoryOld {
  final _repository = [];

  @override
  Future<Either<Failure, Unit>> register(RecordOld value) async {
    if (_repository.every((element) => element.id != value.id)) {
      _repository.add(value);
      return Right(unit);
    }

    return Left(RepositoryFailure());
  }
}
