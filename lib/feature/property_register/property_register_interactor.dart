import 'package:dartz/dartz.dart';

import '../../entity/property.dart';
import '../../util/type/exception_or.dart';
import '../../util/uuid/uuid.dart';
import 'property_register_use_case.dart';

class AddPropertyInteractor implements AddPropertyUseCase {
  @override
  Future<ExceptionOr<Unit>> call(AddPropertyInput input) {
    final repository = input.repository;

    final property = Property(UUID.generate(), input.name, input.amount);

    return repository.register(repoId: input.uid, value: property);
  }
}
