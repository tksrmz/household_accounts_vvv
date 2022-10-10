import 'package:get_it/get_it.dart';

import 'category_use_case.dart';
import 'personal_repository.dart';
import 'property_use_case.dart';
import 'record_use_case.dart';

final sl = GetIt.instance;
bool _slIsInitialized = false;

void initializeServiceLocator() {
  if (_slIsInitialized) {
    return;
  }

  initPersonalRepository(sl);
  initPropertyUseCase(sl);
  initCategoryUseCase(sl);
  initRecordUseCase(sl);
}

/// Register use cases related to shared actions.
// void _initSharedUseCases() {
//   PropertyRepository2 propertyRepo = FirebaseSharedPropertyRepository();
//
//   // Use case - property
//   sl.registerFactory<DeleteSharedPropertyUseCase>(
//     () => DeleteSharedPropertyInteractor(propertyRepo),
//   );
//   sl.registerFactory<UpdateSharedPropertyUseCase>(
//     () => UpdateSharedPropertyInteractor(propertyRepo),
//   );
//   sl.registerFactory<AddSharedPropertyUseCase>(
//     () => AddSharedPropertyInteractor(propertyRepo),
//   );
//   sl.registerFactory<RetrieveSharedPropertiesUseCase>(
//     () => RetrieveSharedPropertiesInteractor(propertyRepo),
//   );
// }
