import 'package:dartz/dartz.dart';
import 'package:household_accounts/features/input-page/domain/entities/record.dart';
import 'package:household_accounts/features/input-page/domain/repositories/record_repository.dart';
import 'package:household_accounts/features/record-calendar-page/domain/use-cases/retrieve_daily_records.dart';
import 'package:household_accounts/features/record-calendar-page/domain/use-cases/retrieve_monthly_records.dart';
import 'package:household_accounts/util/failures/failure.dart';
import 'package:household_accounts/util/extensions/date-time.dart';

/// Retrieves records of the day.
class RetrieveDailyRecordsInteractorNew implements RetrieveDailyRecordsUseCase {
  final RecordRepositoryNew _repository;

  const RetrieveDailyRecordsInteractorNew(this._repository);

  @override
  Future<Either<Failure, List<Record>>> handle(
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
  Future<Either<Failure, List<Record>>> handle(
    RetrieveMonthlyRecordsInput input,
  ) {
    final begin = DateTime(input.year, input.month);
    final end = begin.nextMonth();
    return _repository.retrieveRecordsOf(begin, end);
  }
}
