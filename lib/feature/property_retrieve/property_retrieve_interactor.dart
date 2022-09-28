import 'package:dartz/dartz.dart';
import 'package:household_accounts/entity/property_entity.dart';
import 'package:household_accounts/feature/property_retrieve/property_retrieve_use_case.dart';
import 'package:household_accounts/feature/repository/property_repository.dart';

import '../../util/type/exception_or.dart';

@deprecated
class RetrievePropertiesInteractor extends RetrievePropertiesUseCase {
  final PropertyRepository _repository;

  RetrievePropertiesInteractor(this._repository);

  @override
  Future<ExceptionOr<List<Property>>> call(Unit input) =>
      _repository.retrieveProperties();
}

class RetrievePersonalPropertiesInteractor
    implements RetrievePersonalPropertiesUseCase {
  final PropertyRepository2 _repository;

  RetrievePersonalPropertiesInteractor(this._repository);

  @override
  Future<ExceptionOr<List<Property>>> call(
          RetrievePersonalPropertiesInput input) =>
      _repository.retrieveAll(repoId: input.uid);
}

class RetrieveSharedPropertiesInteractor
    implements RetrieveSharedPropertiesUseCase {
  final PropertyRepository2 _repository;

  RetrieveSharedPropertiesInteractor(this._repository);

  @override
  Future<ExceptionOr<List<Property>>> call(
          RetrieveSharedPropertiesInput input) =>
      _repository.retrieveAll(repoId: input.pairId);
}
