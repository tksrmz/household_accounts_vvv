import 'package:get_it/get_it.dart';

import '../../entity/record_entity.dart';
import '../../feature/record_deletion/delete_expense_record_interactor.dart';
import '../../feature/record_deletion/delete_expense_record_use_case.dart';
import '../../feature/record_deletion/delete_income_record_interactor.dart';
import '../../feature/record_deletion/delete_income_record_use_case.dart';
import '../../feature/record_deletion/delete_transfer_record_interactor.dart';
import '../../feature/record_deletion/delete_transfer_record_use_case.dart';
import '../../feature/record_register/expense_record_register_interactor.dart';
import '../../feature/record_register/expense_record_register_use_case.dart';
import '../../feature/record_register/income_record_register_interactor.dart';
import '../../feature/record_register/income_record_register_use_case.dart';
import '../../feature/record_register/interactor.dart';
import '../../feature/record_register/transfer_record_register_interactor.dart';
import '../../feature/record_register/transfer_record_register_use_case.dart';
import '../../feature/record_register/use_case.dart';
import '../../feature/record_retrieve/retrieve_income_records_interactor.dart';
import '../../feature/record_retrieve/retrieve_income_records_use_case.dart';

void initRecordUseCase(GetIt sl) {
  _initIncomeRecordUseCase(sl);
  _initExpenseRecordUseCase(sl);
  _initTransferRecordUseCase(sl);
}

void _initIncomeRecordUseCase(GetIt sl) {
  sl.registerFactory<AddRecordUseCase<IncomeRecord2>>(
    () => AddRecordInteractor<IncomeRecord2>(),
  );
  // TODO: delete this registration
  sl.registerFactory<AddIncomeRecordUseCase>(
    () => AddIncomeRecordInteractor(),
  );
  sl.registerFactory<RetrieveRecordsUseCase<IncomeRecord>>(
    () => RetrieveRecordsInteractor<IncomeRecord>(),
  );
  sl.registerFactory<DeleteIncomeRecordUseCase>(
    () => DeleteIncomeRecordInteractor(),
  );
}

void _initExpenseRecordUseCase(GetIt sl) {
  sl.registerFactory<AddRecordUseCase<ExpenseRecord2>>(
    () => AddRecordInteractor<ExpenseRecord2>(),
  );
  // TODO: delete this registration
  sl.registerFactory<AddExpenseRecordUseCase>(
    () => AddExpenseRecordInteractor(),
  );
  sl.registerFactory<RetrieveRecordsUseCase<ExpenseRecord>>(
    () => RetrieveRecordsInteractor<ExpenseRecord>(),
  );
  sl.registerFactory<DeleteExpenseRecordUseCase>(
    () => DeleteExpenseRecordInteractor(),
  );
}

void _initTransferRecordUseCase(GetIt sl) {
  sl.registerFactory<AddRecordUseCase<TransferRecord2>>(
    () => AddRecordInteractor<TransferRecord2>(),
  );
  // TODO: delete this registration
  sl.registerFactory<AddTransferRecordUseCase>(
    () => AddTransferRecordInteractor(),
  );
  sl.registerFactory<RetrieveRecordsUseCase<TransferRecord>>(
    () => RetrieveRecordsInteractor<TransferRecord>(),
  );
  sl.registerFactory<DeleteTransferRecordUseCase>(
    () => DeleteTransferRecordInteractor(),
  );
}
