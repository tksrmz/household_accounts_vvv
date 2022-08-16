import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:household_accounts/feature/repository/property_repository.dart';
import 'package:household_accounts/util/type/failure.dart';
import 'package:household_accounts/util/type/use_case.dart';

typedef DeletePropertiesUseCase = UseCase<DeletePropertyInput, Unit>;

class DeletePropertyInput extends Equatable {
  final String id;

  DeletePropertyInput(this.id);

  @override
  List<Object> get props => [id];
}

class DeletePropertyInteractor extends DeletePropertiesUseCase {
  final PropertyRepository _repository;

  DeletePropertyInteractor(this._repository);

  @override
  Future<Either<Failure, Unit>> handle(DeletePropertyInput input) {
    return _repository.deleteById(input.id);
  }
}
