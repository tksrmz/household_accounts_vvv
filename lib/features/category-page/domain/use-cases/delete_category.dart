import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:household_accounts/features/category-page/domain/repositories/category_repository.dart';
import 'package:household_accounts/util/failures/failure.dart';
import 'package:household_accounts/util/use_case.dart';

typedef DeleteCategoryUseCase = UseCase<DeleteCategoryInput, Unit>;

class DeleteCategoryInput extends Equatable {
  final String id;

  const DeleteCategoryInput(this.id);

  @override
  List<Object> get props => [id];
}

@deprecated
class DeleteCategoryInteractor extends DeleteCategoryUseCase {
  final CategoryRepository _repository;

  DeleteCategoryInteractor(this._repository);

  @override
  Future<Either<Failure, Unit>> handle(DeleteCategoryInput input) {
    return _repository.deleteById(input.id);
  }
}
