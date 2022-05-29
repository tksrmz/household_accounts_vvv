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

class ServiceLocator {
  /// Factory constructor
  factory ServiceLocator() {
    if (_sl == null) {
      _sl = ServiceLocator._(false);
    }
    return _sl!;
  }

  /// Private constructor
  ServiceLocator._(this._hasInitialized) : getIt = GetIt.instance;

  static ServiceLocator? _sl;
  final GetIt getIt;
  bool _hasInitialized;

  bool get hasInitialized => _hasInitialized;

  /// Initialize this ServiceLocator.
  /// If this is the first execution on this singleton, `true` is returned.
  /// Otherwise, `false` is returned.
  bool initialize(String uid) {
    if (_hasInitialized) {
      return false;
    }

    // Repositories
    getIt.registerLazySingleton<RecordRepositoryNew>(
      () => FirebaseRecordRepository.personal(uid),
    );
    getIt.registerLazySingleton<PropertyRepository>(
      () => FirebasePropertyRepository.personal(uid),
    );
    getIt.registerLazySingleton<CategoryRepository>(
      () => FirebaseCategoryRepository.personal(uid),
    );

    // Use cases - record
    getIt.registerLazySingleton<AddIncomeRecordUseCase>(
      () => AddIncomeRecordInteractor(getIt<RecordRepositoryNew>()),
    );
    getIt.registerLazySingleton<AddExpenseRecordUseCase>(
      () => AddExpenseRecordInteractor(getIt<RecordRepositoryNew>()),
    );
    getIt.registerLazySingleton<AddTransferRecordUseCase>(
      () => AddTransferRecordInteractor(getIt<RecordRepositoryNew>()),
    );
    getIt.registerLazySingleton<RetrieveMonthlyRecordsUseCase>(
      () => RetrieveMonthlyRecordsInteractorNew(getIt<RecordRepositoryNew>()),
    );
    getIt.registerLazySingleton<RetrieveDailyRecordsUseCase>(
      () => RetrieveDailyRecordsInteractorNew(getIt<RecordRepositoryNew>()),
    );
    getIt.registerLazySingleton<DeleteRecordUseCaseNew>(
      () => DeleteRecordInteractorNew(getIt<RecordRepositoryNew>()),
    );

    // Use cases - property
    getIt.registerLazySingleton<AddPropertiesUseCase>(
      () => AddPropertyInteractor(getIt<PropertyRepository>()),
    );
    getIt.registerLazySingleton<RetrievePropertiesUseCase>(
      () => RetrievePropertiesInteractor(getIt<PropertyRepository>()),
    );
    getIt.registerLazySingleton<UpdatePropertyUseCase>(
      () => UpdatePropertyInteractor(getIt<PropertyRepository>()),
    );
    getIt.registerLazySingleton<DeletePropertiesUseCase>(
      () => DeletePropertyInteractor(getIt<PropertyRepository>()),
    );

    // Use cases - category
    getIt.registerLazySingleton<AddCategoryUseCase>(
      () => AddCategoryInteractor(getIt<CategoryRepository>()),
    );
    getIt.registerLazySingleton<RetrieveCategoriesUseCase>(
      () => RetrieveCategoriesInteractor(getIt<CategoryRepository>()),
    );
    getIt.registerLazySingleton<UpdateCategoryUseCase>(
      () => UpdateCategoryInteractor(getIt<CategoryRepository>()),
    );
    getIt.registerLazySingleton<DeleteCategoryUseCase>(
      () => DeleteCategoryInteractor(getIt<CategoryRepository>()),
    );

    _hasInitialized = true;
    return true;
  }

  /// Retrieves registered instance of Type [T].
  T call<T extends Object>() => getIt<T>();
}
