import 'package:household_accounts/entity/record_entity.dart';
import 'package:household_accounts/feature/record_retrieve/retrieve_daily_records_use_case.dart';
import 'package:household_accounts/feature/record_retrieve/retrieve_monthly_records_use_case.dart';
import 'package:household_accounts/feature/repository/record_repository.dart';
import 'package:household_accounts/util/extension/date-time.dart';

import '../../util/type/exception_or.dart';

/// Retrieves records of the day.
class RetrieveDailyRecordsInteractorNew implements RetrieveDailyRecordsUseCase {
  final RecordRepositoryNew _repository;

  const RetrieveDailyRecordsInteractorNew(this._repository);

  @override
  Future<ExceptionOr<List<Record>>> call(
    RetrieveDailyRecordsInput input,
  ) {
    final begin = DateTime(input.year, input.month, input.day);

    final end = begin.add(Duration(days: 1));

    return _repository.retrieveRecordsOf(begin, end);
  }
}

/// Retrieves records of the month.
class RetrieveMonthlyRecordsInteractorNew
    implements RetrieveMonthlyRecordsUseCase {
  final RecordRepositoryNew _repository;

  const RetrieveMonthlyRecordsInteractorNew(this._repository);

  @override
  Future<ExceptionOr<List<Record>>> call(
    RetrieveMonthlyRecordsInput input,
  ) {
    final begin = DateTime(input.year, input.month);
    final end = begin.nextMonth();
    return _repository.retrieveRecordsOf(begin, end);
  }
}
