import 'package:get_it/get_it.dart';

import '../../feature/category_deletion/delete_expense_category_interactor.dart';
import '../../feature/category_deletion/delete_expense_category_use_case.dart';
import '../../feature/category_deletion/delete_income_category_interactor.dart';
import '../../feature/category_deletion/delete_income_category_use_case.dart';
import '../../feature/category_editing/update_expense_category_interactor.dart';
import '../../feature/category_editing/update_expense_category_use_case.dart';
import '../../feature/category_editing/update_income_category_interactor.dart';
import '../../feature/category_editing/update_income_category_use_case.dart';
import '../../feature/category_register/add_expense_category_interactor.dart';
import '../../feature/category_register/add_expense_category_use_case.dart';
import '../../feature/category_register/add_income_category_interactor.dart';
import '../../feature/category_register/add_income_category_use_case.dart';
import '../../feature/category_retrieve/retrieve_expense_category_interactor.dart';
import '../../feature/category_retrieve/retrieve_expense_category_use_case.dart';
import '../../feature/category_retrieve/retrieve_income_category_interactor.dart';
import '../../feature/category_retrieve/retrieve_income_category_use_case.dart';

void initCategoryUseCase(GetIt sl) {
  _initIncomeCategoryUseCase(sl);
  _initExpenseCategoryUseCase(sl);
}

void _initIncomeCategoryUseCase(GetIt sl) {
  sl.registerFactory<RetrieveIncomeCategoryUseCase>(
    () => RetrieveIncomeCategoryInteractor(),
  );
  sl.registerFactory<UpdateIncomeCategoryUseCase>(
    () => UpdateIncomeCategoryInteractor(),
  );
  sl.registerFactory<AddIncomeCategoryUseCase>(
    () => AddIncomeCategoryInteractor(),
  );
  sl.registerFactory<DeleteIncomeCategoryUseCase>(
    () => DeleteIncomeCategoryInteractor(),
  );
}

void _initExpenseCategoryUseCase(GetIt sl) {
  sl.registerFactory<RetrieveExpenseCategoryUseCase>(
    () => RetrieveExpenseCategoryInteractor(),
  );
  sl.registerFactory<UpdateExpenseCategoryUseCase>(
    () => UpdateExpenseCategoryInteractor(),
  );
  sl.registerFactory<AddExpenseCategoryUseCase>(
    () => AddExpenseCategoryInteractor(),
  );
  sl.registerFactory<DeleteExpenseCategoryUseCase>(
    () => DeleteExpenseCategoryInteractor(),
  );
}
