import '../../../entity/record.dart';
import '../../../feature/record_retrieve/use_case.dart';
import '../../../util/service_locator/main.dart';
import '../../../util/type/exception_or.dart';
import '../../../util/type/single_or_pair.dart';
import '../repository_selector.dart';

Future<ExceptionOr<List<IncomeRecord>>> fetchIncomeRecords({
  required int year,
  required int month,
  int? day,
  required SingleOrPair sop,
  required String repoId,
}) async {
  final fetch = sl<RetrieveRecordsUseCase<IncomeRecord>>();
  final input = RetrieveRecordsInput(
    uid: repoId,
    year: year,
    month: month,
    day: day,
    repository: selectIncomeRecordRepository(sop),
  );
  return fetch(input);
}

Future<ExceptionOr<List<ExpenseRecord>>> fetchExpenseRecords({
  required int year,
  required int month,
  int? day,
  required SingleOrPair sop,
  required String repoId,
}) {
  final fetch = sl<RetrieveRecordsUseCase<ExpenseRecord>>();
  final input = RetrieveRecordsInput(
    uid: repoId,
    year: year,
    month: month,
    day: day,
    repository: selectExpenseRecordRepository(sop),
  );
  return fetch(input);
}

Future<ExceptionOr<List<TransferRecord>>> fetchTransferRecords({
  required int year,
  required int month,
  int? day,
  required SingleOrPair sop,
  required String repoId,
}) {
  final fetch = sl<RetrieveRecordsUseCase<TransferRecord>>();
  final input = RetrieveRecordsInput(
    uid: repoId,
    year: year,
    month: month,
    day: day,
    repository: selectTransferRecordRepository(sop),
  );
  return fetch(input);
}
