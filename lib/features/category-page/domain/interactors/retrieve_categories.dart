import 'package:dartz/dartz.dart';
import 'package:household_accounts/util/domain/entities/category.dart';
import 'package:household_accounts/features/category-page/domain/repositories/category_repository.dart';
import 'package:household_accounts/util/domain/use-cases/retrieve_categories.dart';
import 'package:household_accounts/util/failures/failure.dart';
import 'package:household_accounts/util/use_case.dart';

class RetrieveIncomeCategoriesInteractor
    extends RetrieveIncomeCategoriesUseCase {
  final IncomeCategoryRepository _repository;

  RetrieveIncomeCategoriesInteractor(this._repository);

  @override
  Future<Either<Failure, List<IncomeCategory>>> handle(NoParam notUsed) =>
      _repository.retrieveIncomeCategories();
}

class RetrieveExpenseCategoriesInteractor
    extends RetrieveExpenseCategoriesUseCase {
  final ExpenseCategoryRepository _repository;

  RetrieveExpenseCategoriesInteractor(this._repository);

  @override
  Future<Either<Failure, List<ExpenseCategory>>> handle(NoParam notUsed) =>
      _repository.retrieveExpenseCategories();
}
