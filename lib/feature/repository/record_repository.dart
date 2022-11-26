import '../../entity/record_entity.dart';
import '../../util/type/exception_or.dart';
import '../../util/type/repository.dart';

@deprecated
abstract class PersonalIncomeRecordRepository extends RecordRepository<IncomeRecord> {}

@deprecated
abstract class PersonalExpenseRecordRepository extends RecordRepository<ExpenseRecord> {}

@deprecated
abstract class PersonalTransferRecordRepository extends RecordRepository<TransferRecord> {}

@deprecated
abstract class SharedIncomeRecordRepository extends RecordRepository<IncomeRecord> {}

@deprecated
abstract class SharedExpenseRecordRepository extends RecordRepository<ExpenseRecord> {}

@deprecated
abstract class SharedTransferRecordRepository
    extends RecordRepository<TransferRecord> {}

@deprecated
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

abstract class PersonalIncomeRecordRepository2
    extends RecordRepository2<IncomeRecord2> {}

abstract class PersonalExpenseRecordRepository2
    extends RecordRepository2<ExpenseRecord2> {}

abstract class PersonalTransferRecordRepository2
    extends RecordRepository2<TransferRecord2> {}

abstract class SharedIncomeRecordRepository2
    extends RecordRepository2<IncomeRecord2> {}

abstract class SharedExpenseRecordRepository2
    extends RecordRepository2<ExpenseRecord2> {}

abstract class SharedTransferRecordRepository2
    extends RecordRepository2<TransferRecord2> {}

abstract class RecordRepository2<T extends Record2> extends Repository2<T> {
  @override
  Future<ExceptionOr<List<T>>> retrieveAll({required String repoId}) {
    throw UnsupportedError('DO NOT TRY TO RETRIEVE ALL THE RECORDS.');
  }

  /// Retrieves records in the specified date range ([begin] included, [end] excluded).
  ///
  /// The records are sorted in ascending order of [Record2.dateOfRecord].
  Future<ExceptionOr<List<T>>> retrieveRecordsOf({
    required String repoId,
    required DateTime begin,
    required DateTime end,
  });
}
