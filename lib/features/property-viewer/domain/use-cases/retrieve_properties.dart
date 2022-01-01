import 'package:dartz/dartz.dart';
import 'package:household_accounts/features/property-viewer/domain/entities/property.dart';
import 'package:household_accounts/features/property-viewer/domain/repositories/property_repository.dart';
import 'package:household_accounts/util/failures/failure.dart';
import 'package:household_accounts/util/use_case.dart';

typedef RetrievePropertiesUseCase = UseCase<NoParam, List<Property>>;

class RetrievePropertiesInteractor extends RetrievePropertiesUseCase {
  final PropertyRepository _repository;

  RetrievePropertiesInteractor(this._repository);

  @override
  Future<Either<Failure, List<Property>>> handle(NoParam input) async {
    return await _repository.retrieveProperties();
  }
}
