import 'package:get_it/get_it.dart';

import '../../data/firebase/firebase_expense_category_repository.dart';
import '../../data/firebase/firebase_expense_record_repository.dart';
import '../../data/firebase/firebase_income_category_repository.dart';
import '../../data/firebase/firebase_income_record_repository.dart';
import '../../data/firebase/firebase_property_repository.dart';
import '../../data/firebase/firebase_transfer_record_repository.dart';
import '../../feature/repository/category_repository.dart';
import '../../feature/repository/property_repository.dart';
import '../../feature/repository/record_repository.dart';

/// Register personal repositories.
void initPersonalRepository(GetIt sl) {
  _initPersonalPropertyRepository(sl);
  _initPersonalCategoryRepository(sl);
  _initPersonalRecordRepository(sl);
}

void _initPersonalPropertyRepository(GetIt sl) {
  sl.registerFactory<PersonalPropertyRepository>(
    () => FirebasePersonalPropertyRepository(),
  );
}

void _initPersonalCategoryRepository(GetIt sl) {
  sl.registerFactory<PersonalIncomeCategoryRepository>(
    () => FirebasePersonalIncomeCategoryRepository(),
  );
  sl.registerFactory<PersonalExpenseCategoryRepository>(
    () => FirebasePersonalExpenseCategoryRepository(),
  );
}

void _initPersonalRecordRepository(GetIt sl) {
  sl.registerFactory<PersonalIncomeRecordRepository>(
    () => FirebasePersonalIncomeRecordRepository(),
  );
  sl.registerFactory<PersonalExpenseRecordRepository>(
    () => FirebasePersonalExpenseRecordRepository(),
  );
  sl.registerFactory<PersonalTransferRecordRepository>(
    () => FirebasePersonalTransferRecordRepository(),
  );
}
