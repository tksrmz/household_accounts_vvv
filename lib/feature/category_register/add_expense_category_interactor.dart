import 'package:dartz/dartz.dart';

import '../../entity/category_entity.dart';
import '../../util/type/exception_or.dart';
import '../../util/uuid/uuid.dart';
import 'add_expense_category_use_case.dart';

class AddExpenseCategoryInteractor implements AddExpenseCategoryUseCase {
  @override
  Future<ExceptionOr<Unit>> call(AddExpenseCategoryInput input) {
    final repository = input.repository;

    final category = ExpenseCategory(
      id: UUID.generate(),
      name: input.name,
      totalBudget: input.budget,
    );
    return repository.register(
      repoId: input.uid,
      value: category,
    );
  }
}
