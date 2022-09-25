import 'package:dartz/dartz.dart';
import 'package:household_accounts/entity/property_entity.dart';
import 'package:household_accounts/feature/property_retrieve/property_retrieve_use_case.dart';
import 'package:household_accounts/feature/repository/property_repository.dart';

import '../../util/type/exception_or.dart';

class RetrievePropertiesInteractor extends RetrievePropertiesUseCase {
  final PropertyRepository _repository;

  RetrievePropertiesInteractor(this._repository);

  @override
  Future<ExceptionOr<List<Property>>> call(Unit input) =>
      _repository.retrieveProperties();
}
