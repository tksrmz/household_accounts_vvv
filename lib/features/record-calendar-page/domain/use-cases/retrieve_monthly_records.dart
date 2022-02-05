import 'package:household_accounts/features/input-page/domain/entities/record.dart';
import 'package:household_accounts/util/use_case.dart';

typedef RetrieveMonthlyRecordsUseCase
    = UseCase<RetrieveMonthlyRecordsInput, List<Record>>;

class RetrieveMonthlyRecordsInput {
  final int year;
  final int month;

  RetrieveMonthlyRecordsInput(this.year, this.month);
}
