import 'package:get_it/get_it.dart';

import '../../data/firebase/firebase_expense_category_repository.dart';
import '../../data/firebase/firebase_expense_record_repository.dart';
import '../../data/firebase/firebase_income_category_repository.dart';
import '../../data/firebase/firebase_income_record_repository.dart';
import '../../data/firebase/firebase_property_repository2.dart';
import '../../data/firebase/firebase_transfer_record_repository.dart';
import '../../feature/repository/category_repository.dart';
import '../../feature/repository/property_repository.dart';
import '../../feature/repository/record_repository.dart';

/// Register personal repositories.
void initSharedRepository(GetIt sl) {
  _initSharedPropertyRepository(sl);
  _initSharedCategoryRepository(sl);
  _initSharedRecordRepository(sl);
}

void _initSharedPropertyRepository(GetIt sl) {
  sl.registerFactory<SharedPropertyRepository>(
    () => FirebaseSharedPropertyRepository(),
  );
}

void _initSharedCategoryRepository(GetIt sl) {
  sl.registerFactory<SharedIncomeCategoryRepository>(
    () => FirebaseSharedIncomeCategoryRepository(),
  );
  sl.registerFactory<SharedExpenseCategoryRepository>(
    () => FirebaseSharedExpenseCategoryRepository(),
  );
}

void _initSharedRecordRepository(GetIt sl) {
  sl.registerFactory<SharedIncomeRecordRepository>(
    () => FirebaseSharedIncomeRecordRepository(),
  );
  sl.registerFactory<SharedExpenseRecordRepository>(
    () => FirebaseSharedExpenseRecordRepository(),
  );
  sl.registerFactory<SharedTransferRecordRepository>(
    () => FirebaseSharedTransferRecordRepository(),
  );
}
