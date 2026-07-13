import 'package:flutter/foundation.dart';

import '../../entity/property.dart';
import '../../util/type/exception_or.dart';
import 'property_retrieve_use_case.dart';

class RetrievePropertiesInteractor implements RetrievePropertiesUseCase {
  @override
  Future<ExceptionOr<List<Property>>> call(RetrievePropertiesInput input) {
    debugPrint('$RetrievePropertiesInteractor($input)');
    final repository = input.repository;
    return repository.retrieveAll(repoId: input.uid);
  }
}
