import 'package:get_it/get_it.dart';

import '../../entity/record.dart';
import '../../feature/record_deletion/interactor.dart';
import '../../feature/record_deletion/use_case.dart';
import '../../feature/record_retrieve/interactor.dart';
import '../../feature/record_retrieve/use_case.dart';

void initRecordUseCase(GetIt sl) {
  _initIncomeRecordUseCase(sl);
  _initExpenseRecordUseCase(sl);
  _initTransferRecordUseCase(sl);
}

void _initIncomeRecordUseCase(GetIt sl) {
  sl.registerFactory<RetrieveRecordsUseCase<IncomeRecord>>(
    () => RetrieveRecordsInteractor<IncomeRecord>(),
  );
  sl.registerFactory<DeleteRecordUseCase<IncomeRecord>>(
    () => DeleteRecordInteractor<IncomeRecord>(),
  );
}

void _initExpenseRecordUseCase(GetIt sl) {
  sl.registerFactory<RetrieveRecordsUseCase<ExpenseRecord>>(
    () => RetrieveRecordsInteractor<ExpenseRecord>(),
  );
  sl.registerFactory<DeleteRecordUseCase<ExpenseRecord>>(
    () => DeleteRecordInteractor<ExpenseRecord>(),
  );
}

void _initTransferRecordUseCase(GetIt sl) {
  sl.registerFactory<RetrieveRecordsUseCase<TransferRecord>>(
    () => RetrieveRecordsInteractor<TransferRecord>(),
  );
  sl.registerFactory<DeleteRecordUseCase<TransferRecord>>(
    () => DeleteRecordInteractor<TransferRecord>(),
  );
}
