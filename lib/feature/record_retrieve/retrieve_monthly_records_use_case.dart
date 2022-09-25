import 'package:household_accounts/entity/record_entity.dart';
import 'package:household_accounts/util/type/use_case.dart';

typedef RetrieveMonthlyRecordsUseCase
    = UseCase2<RetrieveMonthlyRecordsInput, List<Record>>;

class RetrieveMonthlyRecordsInput {
  final int year;
  final int month;

  RetrieveMonthlyRecordsInput(this.year, this.month);
}
