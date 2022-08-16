import 'package:dartz/dartz.dart';
import 'package:household_accounts/entity/category_entity.dart';
import 'package:household_accounts/feature/repository/category_repository.dart';
import 'package:household_accounts/feature/category_retrieve/retrieve_categories_use_case.dart';
import 'package:household_accounts/util/type/failure.dart';
import 'package:household_accounts/util/type/use_case.dart';

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
