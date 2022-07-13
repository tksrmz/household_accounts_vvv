import 'package:dartz/dartz.dart';
import 'package:household_accounts/features/category-page/domain/repositories/category_repository.dart';
import 'package:household_accounts/features/category-page/domain/use-cases/add_category.dart';
import 'package:household_accounts/util/domain/entities/category.dart';
import 'package:household_accounts/util/failures/failure.dart';
import 'package:household_accounts/util/uuid.dart';

class AddCategoryInteractor2 extends AddCategoryUseCase2 {
  final IncomeCategoryRepository _incomeCategoryRepository;
  final ExpenseCategoryRepository _expenseCategoryRepository;

  AddCategoryInteractor2(
    this._incomeCategoryRepository,
    this._expenseCategoryRepository,
  );

  @override
  Future<Either<Failure, Unit>> handle(AddCategoryInput2 input) {
    switch (input.type) {
      case CategoryType.income:
        return _incomeCategoryRepository.register(
          IncomeCategory(
            id: UUID.generate(),
            name: input.name,
          ),
        );

      case CategoryType.expense:
        return _expenseCategoryRepository.register(
          ExpenseCategory(
            id: UUID.generate(),
            name: input.name,
            totalBudget: input.budgetAmount,
          ),
        );
    }
  }
}
