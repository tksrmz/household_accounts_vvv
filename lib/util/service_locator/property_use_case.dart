import 'package:get_it/get_it.dart';

import '../../feature/property_deletion/delete_property_interactor.dart';
import '../../feature/property_deletion/delete_property_use_case.dart';
import '../../feature/property_editing/update_property_interactor.dart';
import '../../feature/property_editing/update_property_use_case.dart';
import '../../feature/property_register/property_register_interactor.dart';
import '../../feature/property_register/property_register_use_case.dart';
import '../../feature/property_retrieve/property_retrieve_interactor.dart';
import '../../feature/property_retrieve/property_retrieve_use_case.dart';

void initPropertyUseCase(GetIt sl) {
  sl.registerFactory<AddPropertyUseCase>(
    () => AddPropertyInteractor(),
  );
  sl.registerFactory<RetrievePropertiesUseCase>(
    () => RetrievePropertiesInteractor(),
  );
  sl.registerFactory<UpdatePropertyUseCase>(
    () => UpdatePropertyInteractor(),
  );
  sl.registerFactory<DeletePropertyUseCase>(
    () => DeletePropertyInteractor(),
  );
}
