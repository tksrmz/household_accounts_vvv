import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:household_accounts/feature/repository/property_repository.dart';
import 'package:household_accounts/util/type/use_case.dart';

import '../../util/type/exception_or.dart';

typedef DeletePropertiesUseCase = UseCase2<DeletePropertyInput, Unit>;

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
  Future<ExceptionOr<Unit>> call(DeletePropertyInput input) {
    return _repository.deleteById(input.id);
  }
}
