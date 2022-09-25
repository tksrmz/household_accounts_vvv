import 'package:dartz/dartz.dart';
import 'package:household_accounts/entity/record_entity.dart';

import '../../util/type/exception_or.dart';

/// Base class for repositories that store [Record]
abstract class RecordRepositoryNew {
  /// Registers the [value] in the repository.
  ///
  /// Fails when there is already a record that is identified by [value.id],
  /// or when something goes wrong with the repository.
  Future<ExceptionOr<Unit>> register(Record value);

  /// Retrieves a record with [id] and [type].
  ///
  /// Fails if no records have [id], or
  /// something goes wrong with the repository.
  Future<ExceptionOr<Record>> retrieveById(String id, RecordType type);

  /// Retrieves records in the specified date range ([begin] included, [end] excluded).
  ///
  /// The records are sorted in ascending order of [Record.dateOfRecord].
  Future<ExceptionOr<List<Record>>> retrieveRecordsOf(
      DateTime begin, DateTime end);

  /// Deletes a record with [id] and [type].
  ///
  /// Fails when something goes wrong with the repository.
  ///
  /// It's not a failure that a record with [id] and [type] doesn't exist in the repository.
  /// Such operations do nothing.
  Future<ExceptionOr<Unit>> deleteById(String id, RecordType type);
}
