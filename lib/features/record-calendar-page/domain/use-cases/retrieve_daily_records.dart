import 'package:household_accounts/features/input-page/domain/entities/record.dart';
import 'package:household_accounts/util/use_case.dart';

typedef RetrieveDailyRecordsUseCase
    = UseCase<RetrieveDailyRecordsInput, List<Record>>;

class RetrieveDailyRecordsInput {
  final int year;
  final int month;
  final int day;

  RetrieveDailyRecordsInput(this.year, this.month, this.day);
}
