import 'package:dartz/dartz.dart';

import '../../util/type/exception_or.dart';
import '../../util/type/use_case.dart';
import '../repository/property_repository.dart';

typedef DeletePersonalPropertyUseCase
    = UseCase2<DeletePersonalPropertyInput, Unit>;

class DeletePersonalPropertyInput {
  /// User ID.
  final String uid;

  /// ID of the property to be deleted.
  final String propertyId;

  DeletePersonalPropertyInput({
    required this.uid,
    required this.propertyId,
  });
}

class DeletePersonalPropertyInteractor
    implements DeletePersonalPropertyUseCase {
  final PropertyRepository2 _repository;

  DeletePersonalPropertyInteractor(this._repository);

  @override
  Future<ExceptionOr<Unit>> call(DeletePersonalPropertyInput input) =>
      _repository.deleteById(
        repoId: input.uid,
        id: input.propertyId,
      );
}

typedef DeleteSharedPropertyUseCase = UseCase2<DeleteSharedPropertyInput, Unit>;

class DeleteSharedPropertyInput {
  /// Pair ID.
  final String pairId;

  /// ID of the property to be deleted.
  final String propertyId;

  DeleteSharedPropertyInput({
    required this.pairId,
    required this.propertyId,
  });
}

class DeleteSharedPropertyInteractor implements DeleteSharedPropertyUseCase {
  final PropertyRepository2 _repository;

  DeleteSharedPropertyInteractor(this._repository);

  @override
  Future<ExceptionOr<Unit>> call(DeleteSharedPropertyInput input) =>
      _repository.deleteById(
        repoId: input.pairId,
        id: input.propertyId,
      );
}
