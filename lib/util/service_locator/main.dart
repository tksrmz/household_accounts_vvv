import 'package:get_it/get_it.dart';

import 'category_use_case.dart';
import 'personal_repository.dart';
import 'property_use_case.dart';
import 'record_use_case.dart';
import 'shared_repository.dart';

final sl = GetIt.instance;
bool _slIsInitialized = false;

void initializeServiceLocator() {
  if (_slIsInitialized) {
    return;
  }

  initPersonalRepository(sl);
  initSharedRepository(sl);
  initPropertyUseCase(sl);
  initCategoryUseCase(sl);
  initRecordUseCase(sl);
}
