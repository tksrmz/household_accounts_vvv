import 'package:household_accounts/entity/record_entity.dart';
import 'package:household_accounts/util/type/use_case.dart';

typedef RetrieveDailyRecordsUseCase
    = UseCase2<RetrieveDailyRecordsInput, List<Record>>;

class RetrieveDailyRecordsInput {
  final int year;
  final int month;
  final int day;

  RetrieveDailyRecordsInput(this.year, this.month, this.day);
}
