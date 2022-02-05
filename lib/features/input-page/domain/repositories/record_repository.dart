import 'package:dartz/dartz.dart';
import 'package:household_accounts/features/input-page/domain/entities/record.dart';
import 'package:household_accounts/util/failures/failure.dart';

/// Base class for repositories that store [RecordOld]
abstract class RecordRepositoryOld {
  /// Registers the [value] in the repository.
  ///
  /// Fails when there is already a record that is identified by [value.id],
  /// or when something goes wrong with the repository.
  Future<Either<Failure, Unit>> register(RecordOld value);
}

/// Base class for repositories that store [Record]
abstract class RecordRepository {
  /// Registers the [value] in the repository.
  ///
  /// Fails when there is already a record that is identified by [value.id],
  /// or when something goes wrong with the repository.
  Future<Either<Failure, Unit>> register(Record value);

  /// Retrieves a record that is identified by [id].
  ///
  /// Fails if no records have [id], or
  /// something goes wrong with the repository.
  Future<Either<Failure, Record>> retrieveById(String id);

  /// Retrieves records in the specified date range ([begin] included, [end] excluded).
  ///
  /// The records are sorted in ascending order of [Record.dateOfRecord].
  Future<Either<Failure, List<Record>>> retrieveRecordsOf(
      DateTime begin, DateTime end);

  /// Deletes a record that is identified by [id].
  ///
  /// Fails when something goes wrong with the repository.
  ///
  /// It's not a failure that specifying an ID that doesn't exist in the repository.
  /// Such operations do nothing.
  Future<Either<Failure, Unit>> deleteById(String id);
}
