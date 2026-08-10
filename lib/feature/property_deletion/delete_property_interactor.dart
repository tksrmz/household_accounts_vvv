import 'package:dartz/dartz.dart';

import '../../util/type/exception_or.dart';
import 'delete_property_use_case.dart';

class DeletePropertyInteractor implements DeletePropertyUseCase {
  @override
  Future<ExceptionOr<Unit>> call(DeletePropertyInput input) {
    final repository = input.repository;
    return repository.deleteById(repoId: input.uid, id: input.propertyId);
  }
}
