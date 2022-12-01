import '../../entity/record_entity.dart';
import '../../util/type/exception_or.dart';
import 'use_case.dart';

class RetrieveRecordsInteractor<T extends RecordBase>
    implements RetrieveRecordsUseCase<T> {
  @override
  Future<ExceptionOr<List<T>>> call(
    RetrieveRecordsInput<T> input,
  ) =>
      input.repository.retrieveRecordsOf(
        repoId: input.uid,
        begin: _calculateBeginDateTime(
          input.year,
          input.month,
          input.day,
        ),
        end: _calculateEndDateTime(
          input.year,
          input.month,
          input.day,
        ),
      );

  DateTime _calculateBeginDateTime(
    int year,
    int? month,
    int? day,
  ) =>
      DateTime(year, month ?? 1, day ?? 1);

  DateTime _calculateEndDateTime(
    int year,
    int? month,
    int? day,
  ) {
    if (month == null && day == null) {
      return DateTime(year + 1);
    }

    assert(month != null, 'month is null!');

    if (day == null) {
      return DateTime(year, month! + 1);
    }

    return DateTime(year, month!, day + 1);
  }
}
