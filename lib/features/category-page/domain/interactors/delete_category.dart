import 'package:dartz/dartz.dart';
import 'package:household_accounts/features/category-page/domain/repositories/category_repository.dart';
import 'package:household_accounts/features/category-page/domain/use-cases/delete_category.dart';
import 'package:household_accounts/util/failures/failure.dart';

class DeleteIncomeCategoryInteractor extends DeleteIncomeCategoryUseCase {
  final IncomeCategoryRepository _repository;

  DeleteIncomeCategoryInteractor(this._repository);

  @override
  Future<Either<Failure, Unit>> handle(DeleteIncomeCategoryInput input) =>
      _repository.deleteById(input.id);
}

class DeleteExpenseCategoryInteractor extends DeleteExpenseCategoryUseCase {
  final ExpenseCategoryRepository _repository;

  DeleteExpenseCategoryInteractor(this._repository);

  @override
  Future<Either<Failure, Unit>> handle(DeleteExpenseCategoryInput input) =>
      _repository.deleteById(input.id);
}
