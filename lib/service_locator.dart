import 'package:get_it/get_it.dart';
import 'package:household_accounts/features/category-page/data/repositories/firebase_category_repository.dart';
import 'package:household_accounts/features/category-page/domain/interactors/retrieve_categories.dart';
import 'package:household_accounts/features/category-page/domain/repositories/category_repository.dart';
import 'package:household_accounts/features/category-page/domain/use-cases/add_category.dart';
import 'package:household_accounts/features/category-page/domain/use-cases/delete_category.dart';
import 'package:household_accounts/features/category-page/domain/use-cases/update_category.dart';
import 'package:household_accounts/features/input-page/data/repositories/firebase_record_repository.dart';
import 'package:household_accounts/features/input-page/domain/repositories/record_repository.dart';
import 'package:household_accounts/features/input-page/domain/use-cases/add_record.dart';
import 'package:household_accounts/features/property-viewer/data/repositories/firebase_property_repository.dart';
import 'package:household_accounts/features/property-viewer/domain/interactors/retrieve_properties.dart';
import 'package:household_accounts/features/property-viewer/domain/repositories/property_repository.dart';
import 'package:household_accounts/features/property-viewer/domain/use-cases/add_properties.dart';
import 'package:household_accounts/features/property-viewer/domain/use-cases/delete_property.dart';
import 'package:household_accounts/features/property-viewer/domain/use-cases/update_property.dart';
import 'package:household_accounts/features/record-calendar-page/domain/interactors/delete_record.dart';
import 'package:household_accounts/features/record-calendar-page/domain/interactors/retrieve_records.dart';
import 'package:household_accounts/features/record-calendar-page/domain/use-cases/delete_record.dart';
import 'package:household_accounts/features/record-calendar-page/domain/use-cases/retrieve_daily_records.dart';
import 'package:household_accounts/features/record-calendar-page/domain/use-cases/retrieve_monthly_records.dart';
import 'package:household_accounts/util/domain/use-cases/retrieve_categories.dart';
import 'package:household_accounts/util/domain/use-cases/retrieve_properties.dart';

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
  sl.registerLazySingleton<CategoryRepository>(
    () => FirebaseCategoryRepository.personal(uid),
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
  sl.registerLazySingleton<AddCategoryUseCase>(
        () => AddCategoryInteractor(sl<CategoryRepository>()),
  );
  sl.registerLazySingleton<RetrieveCategoriesUseCase>(
        () => RetrieveCategoriesInteractor(sl<CategoryRepository>()),
  );
  sl.registerLazySingleton<UpdateCategoryUseCase>(
        () => UpdateCategoryInteractor(sl<CategoryRepository>()),
  );
  sl.registerLazySingleton<DeleteCategoryUseCase>(
        () => DeleteCategoryInteractor(sl<CategoryRepository>()),
  );
}