import 'package:dartz/dartz.dart';
import 'package:household_accounts/util/domain/entities/category.dart';
import 'package:household_accounts/features/category-page/domain/repositories/category_repository.dart';
import 'package:household_accounts/util/domain/use-cases/retrieve_categories.dart';
import 'package:household_accounts/util/failures/failure.dart';
import 'package:household_accounts/util/use_case.dart';

@deprecated
class RetrieveCategoriesInteractor extends RetrieveCategoriesUseCase {
  final CategoryRepository _repository;

  RetrieveCategoriesInteractor(this._repository);

  @override
  Future<Either<Failure, List<Category>>> handle(NoParam noParam) =>
      _repository.retrieveCategories();
}

class RetrieveIncomeCategoriesInteractor
    extends RetrieveIncomeCategoriesUseCase {
  final CategoryRepository2 _repository;

  RetrieveIncomeCategoriesInteractor(this._repository);

  @override
  Future<Either<Failure, List<IncomeCategory>>> handle(NoParam notUsed) =>
      _repository.retrieveIncomeCategories();
}

class RetrieveExpenseCategoriesInteractor
    extends RetrieveExpenseCategoriesUseCase {
  final CategoryRepository2 _repository;

  RetrieveExpenseCategoriesInteractor(this._repository);

  @override
  Future<Either<Failure, List<ExpenseCategory>>> handle(NoParam notUsed) =>
      _repository.retrieveExpenseCategories();
}
