import 'package:household_accounts/entity/record.dart';
import 'package:household_accounts/use_case/uc_repository.dart';
import 'package:household_accounts/use_case/use_case.dart';

typedef RetrieveMonthlyRecordsUseCase
    = UseCase<RetrieveMonthlyRecordsInput, List<Record>>;

class RetrieveMonthlyRecordsInput {
  final int _year;
  final int _month;

  RetrieveMonthlyRecordsInput(this._year, this._month);

  int get year => _year;

  int get month => _month;
}

/// Retrieves records of the month.
class RetrieveMonthlyRecordsInteractor
    implements RetrieveMonthlyRecordsUseCase {
  final RecordRepositoryInterface _repository;

  const RetrieveMonthlyRecordsInteractor(this._repository);

  @override
  Future<List<Record>> handle(RetrieveMonthlyRecordsInput input) {
    final begin = DateTime(input._year, input._month);
    assert(
      DateTime.now().isAfter(begin),
      'Retrieving future records. (${input._year}/${input._month}',
    );

    final end = input._month == DateTime.december
        ? DateTime(input._year + 1, DateTime.january)
        : DateTime(input._year, input._month + 1);
    return _repository.retrieveRecordsOf(begin, end);
  }
}
