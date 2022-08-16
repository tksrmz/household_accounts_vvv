import 'package:dartz/dartz.dart';
import 'package:household_accounts/entity/property_entity.dart';
import 'package:household_accounts/feature/repository/property_repository.dart';
import 'package:household_accounts/feature/property_retrieve/property_retrieve_use_case.dart';
import 'package:household_accounts/util/type/failure.dart';
import 'package:household_accounts/util/type/use_case.dart';

class RetrievePropertiesInteractor extends RetrievePropertiesUseCase {
  final PropertyRepository _repository;

  RetrievePropertiesInteractor(this._repository);

  @override
  Future<Either<Failure, List<Property>>> handle(NoParam input) async {
    return await _repository.retrieveProperties();
  }
}
