import 'package:get_it/get_it.dart';

import '../../entity/record_entity.dart';
import '../../feature/record_deletion/interactor.dart';
import '../../feature/record_deletion/use_case.dart';
import '../../feature/record_register/interactor.dart';
import '../../feature/record_register/use_case.dart';
import '../../feature/record_retrieve/interactor.dart';
import '../../feature/record_retrieve/use_case.dart';

void initRecordUseCase(GetIt sl) {
  _initIncomeRecordUseCase(sl);
  _initExpenseRecordUseCase(sl);
  _initTransferRecordUseCase(sl);
}

void _initIncomeRecordUseCase(GetIt sl) {
  sl.registerFactory<AddRecordUseCase<IncomeRecord2>>(
    () => AddRecordInteractor<IncomeRecord2>(),
  );
  sl.registerFactory<RetrieveRecordsUseCase<IncomeRecord2>>(
    () => RetrieveRecordsInteractor<IncomeRecord2>(),
  );
  sl.registerFactory<DeleteRecordUseCase<IncomeRecord2>>(
    () => DeleteRecordInteractor<IncomeRecord2>(),
  );
}

void _initExpenseRecordUseCase(GetIt sl) {
  sl.registerFactory<AddRecordUseCase<ExpenseRecord2>>(
    () => AddRecordInteractor<ExpenseRecord2>(),
  );
  sl.registerFactory<RetrieveRecordsUseCase<ExpenseRecord2>>(
    () => RetrieveRecordsInteractor<ExpenseRecord2>(),
  );
  sl.registerFactory<DeleteRecordUseCase<ExpenseRecord2>>(
    () => DeleteRecordInteractor<ExpenseRecord2>(),
  );
}

void _initTransferRecordUseCase(GetIt sl) {
  sl.registerFactory<AddRecordUseCase<TransferRecord2>>(
    () => AddRecordInteractor<TransferRecord2>(),
  );
  sl.registerFactory<RetrieveRecordsUseCase<TransferRecord2>>(
    () => RetrieveRecordsInteractor<TransferRecord2>(),
  );
  sl.registerFactory<DeleteRecordUseCase<TransferRecord2>>(
    () => DeleteRecordInteractor<TransferRecord2>(),
  );
}
