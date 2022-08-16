import 'package:get_it/get_it.dart';
import 'package:household_accounts/feature/budget_analyzer/budget_analyzer_interactor.dart';
import 'package:household_accounts/feature/budget_analyzer/budget_analyzer_use_case.dart';
import 'package:household_accounts/data/firebase/firebase_category_repository.dart';
import 'package:household_accounts/feature/category_retrieve/retrieve_categories_interactor.dart';
import 'package:household_accounts/feature/repository/category_repository.dart';
import 'package:household_accounts/feature/category_register/category_register_use_case.dart';
import 'package:household_accounts/feature/category_deletion/delete_category_use_case.dart';
import 'package:household_accounts/feature/category_editing/update_category_use_case.dart';
import 'package:household_accounts/data/firebase/firebase_record_repository.dart';
import 'package:household_accounts/feature/category_retrieve/retrieve_categories_use_case.dart';
import 'package:household_accounts/feature/repository/record_repository.dart';
import 'package:household_accounts/feature/record_register/record_register_use_case.dart';
import 'package:household_accounts/data/firebase/firebase_property_repository.dart';
import 'package:household_accounts/feature/property_retrieve/property_retrieve_interactor.dart';
import 'package:household_accounts/feature/repository/property_repository.dart';
import 'package:household_accounts/feature/property_register/property_register_use_case.dart';
import 'package:household_accounts/feature/property_deletion/delete_property_use_case.dart';
import 'package:household_accounts/feature/property_editing/update_property_use_case.dart';
import 'package:household_accounts/feature/record_deletion/delete_record_interactor.dart';
import 'package:household_accounts/feature/record_retrieve/retrieve_records_interactor.dart';
import 'package:household_accounts/feature/record_deletion/delete_record_use_case.dart';
import 'package:household_accounts/feature/record_retrieve/retrieve_daily_records_use_case.dart';
import 'package:household_accounts/feature/record_retrieve/retrieve_monthly_records_use_case.dart';
import 'package:household_accounts/feature/property_retrieve/property_retrieve_use_case.dart';

import 'package:household_accounts/feature/category_register/category_register_interactor.dart';
import 'package:household_accounts/feature/category_deletion/delete_category_interactor.dart';
import 'package:household_accounts/feature/category_editing/update_category_interactor.dart';

final sl = GetIt.instance;
bool _slIsInitialized = false;

void initialize(String uid) {
  if (_slIsInitialized) {
    return;
  }

  // Repositories
  sl.registerLazySingleton<RecordRepositoryNew>(
    () => FirebaseRecordRepository.personal(uid),
  );
  sl.registerLazySingleton<PropertyRepository>(
    () => FirebasePropertyRepository.personal(uid),
  );
  sl.registerLazySingleton<IncomeCategoryRepository>(
    // () => InMemoryIncomeCategoryRepository(),
    () => FirebaseIncomeCategoryRepository.personal(uid),
  );
  sl.registerLazySingleton<ExpenseCategoryRepository>(
    // () => InMemoryExpenseCategoryRepository(),
    () => FirebaseExpenseCategoryRepository.personal(uid),
  );

  // Use cases - record
  sl.registerLazySingleton<AddIncomeRecordUseCase>(
    () => AddIncomeRecordInteractor(sl<RecordRepositoryNew>()),
  );
  sl.registerLazySingleton<AddExpenseRecordUseCase>(
    () => AddExpenseRecordInteractor(sl<RecordRepositoryNew>()),
  );
  sl.registerLazySingleton<AddTransferRecordUseCase>(
    () => AddTransferRecordInteractor(sl<RecordRepositoryNew>()),
  );
  sl.registerLazySingleton<RetrieveMonthlyRecordsUseCase>(
        () => RetrieveMonthlyRecordsInteractorNew(sl<RecordRepositoryNew>()),
  );
  sl.registerLazySingleton<RetrieveDailyRecordsUseCase>(
        () => RetrieveDailyRecordsInteractorNew(sl<RecordRepositoryNew>()),
  );
  sl.registerLazySingleton<DeleteRecordUseCaseNew>(
        () => DeleteRecordInteractorNew(sl<RecordRepositoryNew>()),
  );

  // Use cases - property
  sl.registerLazySingleton<AddPropertiesUseCase>(
        () => AddPropertyInteractor(sl<PropertyRepository>()),
  );
  sl.registerLazySingleton<RetrievePropertiesUseCase>(
        () => RetrievePropertiesInteractor(sl<PropertyRepository>()),
  );
  sl.registerLazySingleton<UpdatePropertyUseCase>(
        () => UpdatePropertyInteractor(sl<PropertyRepository>()),
  );
  sl.registerLazySingleton<DeletePropertiesUseCase>(
        () => DeletePropertyInteractor(sl<PropertyRepository>()),
  );

  // Use cases - category
  sl.registerLazySingleton<AddCategoryUseCase2>(
    () => AddCategoryInteractor2(
      sl<IncomeCategoryRepository>(),
      sl<ExpenseCategoryRepository>(),
    ),
  );
  sl.registerLazySingleton<RetrieveIncomeCategoriesUseCase>(
    () => RetrieveIncomeCategoriesInteractor(
      sl<IncomeCategoryRepository>(),
    ),
  );
  sl.registerLazySingleton<UpdateIncomeCategoryUseCase>(
    () => UpdateIncomeCategoryInteractor(
      sl<IncomeCategoryRepository>(),
    ),
  );
  sl.registerLazySingleton<DeleteIncomeCategoryUseCase>(
    () => DeleteIncomeCategoryInteractor(
      sl<IncomeCategoryRepository>(),
    ),
  );
  sl.registerLazySingleton<RetrieveExpenseCategoriesUseCase>(
    () => RetrieveExpenseCategoriesInteractor(
      sl<ExpenseCategoryRepository>(),
    ),
  );
  sl.registerLazySingleton<UpdateExpenseCategoryUseCase>(
    () => UpdateExpenseCategoryInteractor(
      sl<ExpenseCategoryRepository>(),
    ),
  );
  sl.registerLazySingleton<DeleteExpenseCategoryUseCase>(
    () => DeleteExpenseCategoryInteractor(
      sl<ExpenseCategoryRepository>(),
    ),
  );

  // Use cases - budget
  sl.registerLazySingleton<RetrieveBudgetStateUseCase>(
    () => RetrieveBudgetStateInteractor(
      sl<RecordRepositoryNew>(),
      sl<ExpenseCategoryRepository>(),
    ),
  );
}
