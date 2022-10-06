import 'package:dartz/dartz.dart';

import '../../entity/record_entity.dart';
import '../../util/type/exception_or.dart';
import '../../util/type/repository.dart';

/// Base class for repositories that store [Record]
@deprecated
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
    DateTime begin,
    DateTime end,
  );

  /// Deletes a record with [id] and [type].
  ///
  /// Fails when something goes wrong with the repository.
  ///
  /// It's not a failure that a record with [id] and [type] doesn't exist in the repository.
  /// Such operations do nothing.
  Future<ExceptionOr<Unit>> deleteById(String id, RecordType type);
}

abstract class PersonalIncomeRecordRepository
    extends RecordRepository<IncomeRecord> {}

abstract class PersonalExpenseRecordRepository
    extends RecordRepository<ExpenseRecord> {}

abstract class PersonalTransferRecordRepository
    extends RecordRepository<TransferRecord> {}

abstract class SharedIncomeRecordRepository
    extends RecordRepository<IncomeRecord> {}

abstract class SharedExpenseRecordRepository
    extends RecordRepository<ExpenseRecord> {}

abstract class SharedTransferRecordRepository
    extends RecordRepository<TransferRecord> {}

abstract class RecordRepository<T extends Record> extends Repository2<T> {
  @override
  Future<ExceptionOr<List<T>>> retrieveAll({required String repoId}) {
    throw UnsupportedError('DO NOT TRY TO RETRIEVE ALL THE RECORDS.');
  }

  /// Retrieves records in the specified date range ([begin] included, [end] excluded).
  ///
  /// The records are sorted in ascending order of [Record.dateOfRecord].
  Future<ExceptionOr<List<T>>> retrieveRecordsOf({
    required String repoId,
    required DateTime begin,
    required DateTime end,
  });
}
