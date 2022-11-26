import '../../entity/record_entity.dart';
import '../../util/extension/date-time.dart';
import '../../util/type/exception_or.dart';
import 'retrieve_income_records_use_case.dart';

@deprecated
class RetrieveRecordsInteractor<T extends Record>
    implements RetrieveRecordsUseCase<T> {
  @override
  Future<ExceptionOr<List<T>>> call(
    RetrieveRecordsInput<T> input,
  ) {
    final repository = input.repository;

    final begin = _calculateBeginDateTime(
      input.year,
      input.month,
      input.day,
    );
    final end = _calculateEndDateTime(
      input.year,
      input.month,
      input.day,
    );
    return repository.retrieveRecordsOf(
      repoId: input.uid,
      begin: begin,
      end: end,
    );
  }

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
      return DateTime(year, month!).nextMonth();
    }

    return DateTime(year, month!, day).add(Duration(days: 1));
  }
}
