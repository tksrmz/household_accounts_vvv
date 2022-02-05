import 'package:household_accounts/entity/record.dart';
import 'package:household_accounts/features/record-calendar-page/domain/repositories/uc_repository.dart';
import 'package:household_accounts/use_case/use_case.dart';

typedef RetrieveDailyRecordsUseCase
    = UseCase<RetrieveDailyRecordsInput, List<Record>>;

class RetrieveDailyRecordsInput {
  final int _year;
  final int _month;
  final int _day;

  RetrieveDailyRecordsInput(this._year, this._month, this._day);

  int get year => _year;

  int get month => _month;

  int get day => _day;
}

/// Retrieves records of the day.
class RetrieveDailyRecordsInteractor implements RetrieveDailyRecordsUseCase {
  final RecordRepositoryInterface _repository;

  const RetrieveDailyRecordsInteractor(this._repository);

  @override
  Future<List<Record>> handle(RetrieveDailyRecordsInput input) {
    final begin = DateTime(input._year, input._month, input._day);
    assert(
      DateTime.now().isAfter(begin),
      'Retrieving future records. (${input._year}/${input._month}/${input._day}',
    );

    final end = begin.add(Duration(days: 1));

    return _repository.retrieveRecordsOf(begin, end);
  }
}
