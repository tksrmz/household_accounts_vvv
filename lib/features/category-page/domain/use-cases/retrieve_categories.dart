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

class RetrieveCategoriesInteractor extends RetrieveCategoriesUseCase {
  RetrieveCategoriesInteractor(CategoryRepository repository)
      : super(repository);

  @override
  Future<Either<Failure, List<Category>>> handle(NoParam noParam) =>
      _repository.retrieveCategories();
}
