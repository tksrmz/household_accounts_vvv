import 'package:dartz/dartz.dart';
import 'package:household_accounts/features/input-page/domain/entities/record.dart';
import 'package:household_accounts/util/failures/failure.dart';

/// Base class for repositories that store [Record]
abstract class RecordRepository {
  /// Registers the [value] in the repository.
  ///
  /// Fails when there is already a record that is identified by [value.id],
  /// or when something goes wrong with the repository.
  Future<Either<Failure, Unit>> register(Record value);
}
