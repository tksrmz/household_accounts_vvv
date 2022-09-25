import 'package:dartz/dartz.dart';
import 'package:household_accounts/entity/category_entity.dart';
import 'package:household_accounts/feature/category_editing/update_category_use_case.dart';
import 'package:household_accounts/feature/repository/category_repository.dart';

import '../../util/type/exception_or.dart';

class UpdateIncomeCategoryInteractor extends UpdateIncomeCategoryUseCase {
  final IncomeCategoryRepository _repository;

  UpdateIncomeCategoryInteractor(this._repository);

  @override
  Future<ExceptionOr<Unit>> call(UpdateIncomeCategoryInput input) =>
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
  Future<ExceptionOr<Unit>> call(UpdateExpenseCategoryInput input) =>
      _repository.update(
        ExpenseCategory(
          id: input.original.id,
          name: input.newName ?? input.original.name,
          totalBudget: input.newBudgetAmount ?? input.original.totalBudget,
        ),
      );
}
