import 'package:dartz/dartz.dart';
import 'package:household_accounts/features/category-page/domain/repositories/category_repository.dart';
import 'package:household_accounts/features/category-page/domain/use-cases/add_category.dart';
import 'package:household_accounts/util/domain/entities/category.dart';
import 'package:household_accounts/util/failures/failure.dart';
import 'package:household_accounts/util/uuid.dart';

class AddCategoryInteractor2 extends AddCategoryUseCase2 {
  final CategoryRepository2 _repository;

  AddCategoryInteractor2(this._repository);

  @override
  Future<Either<Failure, Category2>> handle(AddCategoryInput2 input) async {
    final Category2 category;
    switch (input.type) {
      case CategoryType.income:
        category = IncomeCategory(
          id: UUID.generate(),
          name: input.name,
        );
        break;

      case CategoryType.expense:
        category = ExpenseCategory(
          id: UUID.generate(),
          name: input.name,
          totalBudget: input.budgetAmount,
        );
        break;
    }

    final result = await _repository.register(category);
    return result.replace(category);
  }
}
