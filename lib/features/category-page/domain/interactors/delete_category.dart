import 'package:dartz/dartz.dart';
import 'package:household_accounts/features/category-page/domain/repositories/category_repository.dart';
import 'package:household_accounts/features/category-page/domain/use-cases/delete_category.dart';
import 'package:household_accounts/util/failures/failure.dart';

class DeleteCategoryInteractor2 extends DeleteCategoryUseCase {
  final CategoryRepository2 _repository;

  DeleteCategoryInteractor2(this._repository);

  @override
  Future<Either<Failure, Unit>> handle(DeleteCategoryInput input) =>
      _repository.deleteById(input.id);
}
