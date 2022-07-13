import 'package:dartz/dartz.dart';
import 'package:household_accounts/features/category-page/domain/repositories/category_repository.dart';
import 'package:household_accounts/features/category-page/domain/use-cases/update_category.dart';
import 'package:household_accounts/util/domain/entities/category.dart';
import 'package:household_accounts/util/failures/failure.dart';

class UpdateIncomeCategoryInteractor extends UpdateIncomeCategoryUseCase {
  final IncomeCategoryRepository _repository;

  UpdateIncomeCategoryInteractor(this._repository);

  @override
  Future<Either<Failure, Unit>> handle(UpdateIncomeCategoryInput input) =>
      _repository.update(
        IncomeCategory(
          id: input.original.id,
          name: input.newName ?? input.original.name,
        ),
      );
}

class UpdateExpenseCategoryInteractor extends UpdateExpenseCategoryUseCase {
  final ExpenseCategoryRepository _repository;

  UpdateExpenseCategoryInteractor(this._repository);

  @override
  Future<Either<Failure, Unit>> handle(UpdateExpenseCategoryInput input) =>
      _repository.update(
        ExpenseCategory(
          id: input.original.id,
          name: input.newName ?? input.original.name,
          totalBudget: input.newBudgetAmount ?? input.original.totalBudget,
        ),
      );
}
