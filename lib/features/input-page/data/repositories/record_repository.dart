import 'package:dartz/dartz.dart';
import 'package:household_accounts/features/input-page/domain/entities/record.dart';
import 'package:household_accounts/features/input-page/domain/repositories/record_repository.dart';
import 'package:household_accounts/features/property-viewer/domain/repositories/property_repository.dart';
import 'package:household_accounts/util/domain/entities/property.dart';
import 'package:household_accounts/util/failures/failure.dart';

class InMemoryRecordRepository implements RecordRepository {
  final _repository = [];
  final PropertyRepository _propertyRepository;

  InMemoryRecordRepository(this._propertyRepository);

  @override
  Future<Either<Failure, Unit>> register(Record value) async {
    if (value is IncomeRecord) {
      return _registerIncome(value);
    }
    if (value is ExpenseRecord) {
      return _registerExpense(value);
    }
    if (value is TransferRecord) {
      return _registerTransfer(value);
    }

    return Left(RepositoryFailure());
  }

  bool _repositoryHasId(String id) {
    return _repository.any((record) => record.id == id);
  }

  bool _repositoryDoesNotHaveId(String id) {
    return !_repositoryHasId(id);
  }

  Future<Either<Failure, Unit>> _registerIncome(IncomeRecord income) async {
    final failureOrProperty =
        await _propertyRepository.retrieveById(income.propertyId);
    return failureOrProperty.fold<Either<Failure, Unit>>(
      (failure) {
        return Left(failure);
      },
      (property) {
        if (_repositoryDoesNotHaveId(income.id)) {
          _propertyRepository.update(
            Property(
              property.id,
              property.name,
              property.amount + income.amount,
            ),
          );
          _repository.add(income);
          return Right(unit);
        }

        return Left(RepositoryFailure());
      },
    );
  }

  Future<Either<Failure, Unit>> _registerExpense(ExpenseRecord expense) async {
    final failureOrProperty =
        await _propertyRepository.retrieveById(expense.propertyId);
    return failureOrProperty.fold<Either<Failure, Unit>>(
      (failure) {
        return Left(failure);
      },
      (property) {
        if (_repositoryDoesNotHaveId(expense.id)) {
          _propertyRepository.update(
            Property(
              property.id,
              property.name,
              property.amount - expense.amount,
            ),
          );
          _repository.add(expense);
          return Right(unit);
        }

        return Left(RepositoryFailure());
      },
    );
  }

  Future<Either<Failure, Unit>> _registerTransfer(
    TransferRecord transfer,
  ) async {
    if (transfer.srcPropertyId == transfer.destPropertyId) {
      return Left(RepositoryFailure());
    }

    final failureOrSrcProperty =
        await _propertyRepository.retrieveById(transfer.srcPropertyId);
    final failureOrDestProperty =
        await _propertyRepository.retrieveById(transfer.destPropertyId);

    return failureOrSrcProperty.fold(
      (failure) => Left(failure),
      (src) => failureOrDestProperty.fold((failure) => Left(failure), (dest) {
        if (_repositoryDoesNotHaveId(transfer.id)) {
          _propertyRepository.update(
            Property(
              src.id,
              src.name,
              src.amount - transfer.amount,
            ),
          );
          _propertyRepository.update(
            Property(
              dest.id,
              dest.name,
              dest.amount + transfer.amount,
            ),
          );
          _repository.add(transfer);

          return Right(unit);
        }
        return Left(RepositoryFailure());
      }),
    );
  }
}
