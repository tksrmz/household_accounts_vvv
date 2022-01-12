import 'package:dartz/dartz.dart';
import 'package:household_accounts/features/category-page/domain/entities/category.dart';
import 'package:household_accounts/features/category-page/domain/repositories/category_repository.dart';
import 'package:household_accounts/util/failures/failure.dart';
import 'package:household_accounts/util/use_case.dart';

abstract class RetrieveCategoriesUseCase
    extends UseCase<NoParam, List<Category>> {
  final CategoryRepository _repository;

  RetrieveCategoriesUseCase(this._repository);
}

class RetrieveAllCategoriesInteractor extends RetrieveCategoriesUseCase {
  RetrieveAllCategoriesInteractor(CategoryRepository repository)
      : super(repository);

  @override
  Future<Either<Failure, List<Category>>> handle(NoParam noParam) =>
      _repository.retrieveCategories();
}

// FIXME: RetrieveIncomeCategoriesInteractor and RetrieveExpenseCategoriesInteractor is almost same.
class RetrieveIncomeCategoriesInteractor extends RetrieveCategoriesUseCase {
  RetrieveIncomeCategoriesInteractor(CategoryRepository repository)
      : super(repository);

  @override
  Future<Either<Failure, List<Category>>> handle(NoParam noParam) async {
    final failureOrCategories = await _repository.retrieveCategories();
    return failureOrCategories.map(
      (categories) => List.of(
        categories.where(
          (element) => element.type == CategoryType.income,
        ),
      ),
    );
  }
}

class RetrieveExpenseCategoriesInteractor extends RetrieveCategoriesUseCase {
  RetrieveExpenseCategoriesInteractor(CategoryRepository repository)
      : super(repository);

  @override
  Future<Either<Failure, List<Category>>> handle(NoParam noParam) async {
    final failureOrCategories = await _repository.retrieveCategories();
    return failureOrCategories.map(
      (categories) => List.of(
        categories.where(
          (element) => element.type == CategoryType.expense,
        ),
      ),
    );
  }
}
