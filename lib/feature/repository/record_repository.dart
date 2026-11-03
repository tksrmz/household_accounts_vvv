import '../../entity/record.dart';
import '../../util/type/exception_or.dart';
import '../../util/type/repository.dart';

abstract class PersonalExpenseRecordRepository
    extends RecordRepository<ExpenseRecord> {}

abstract class SharedExpenseRecordRepository
    extends RecordRepository<ExpenseRecord> {}

abstract class RecordRepository<T extends RecordBase> extends Repository<T> {
  @override
  Future<ExceptionOr<List<T>>> retrieveAll({required String repoId}) {
    throw UnsupportedError('DO NOT TRY TO RETRIEVE ALL THE RECORDS.');
  }

  /// Retrieves records in the specified date range ([begin] included, [end] excluded).
  ///
  /// The records are sorted in ascending order of [RecordBase.dateOfRecord].
  Future<ExceptionOr<List<T>>> retrieveRecordsOf({
    required String repoId,
    required DateTime begin,
    required DateTime end,
  });
}
