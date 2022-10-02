import '../../entity/property_entity.dart';
import '../../util/type/exception_or.dart';
import '../repository/property_repository.dart';
import 'property_retrieve_use_case.dart';

@deprecated
class RetrievePersonalPropertiesInteractor
    implements RetrievePersonalPropertiesUseCase {
  final PropertyRepository2 _repository;

  RetrievePersonalPropertiesInteractor(this._repository);

  @override
  Future<ExceptionOr<List<Property>>> call(
          RetrievePersonalPropertiesInput input) =>
      _repository.retrieveAll(repoId: input.uid);
}

@deprecated
class RetrieveSharedPropertiesInteractor
    implements RetrieveSharedPropertiesUseCase {
  final PropertyRepository2 _repository;

  RetrieveSharedPropertiesInteractor(this._repository);

  @override
  Future<ExceptionOr<List<Property>>> call(
          RetrieveSharedPropertiesInput input) =>
      _repository.retrieveAll(repoId: input.pairId);
}

class RetrievePropertiesInteractor implements RetrievePropertiesUseCase {
  @override
  Future<ExceptionOr<List<Property>>> call(RetrievePropertiesInput input) {
    final repository = input.repository;
    return repository.retrieveAll(repoId: input.uid);
  }
}
