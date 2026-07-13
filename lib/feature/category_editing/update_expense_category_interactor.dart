import 'package:dartz/dartz.dart';

import '../../entity/category.dart';
import '../../util/method/future_either.dart';
import '../../util/type/exception_or.dart';
import 'update_expense_category_use_case.dart';

class UpdateExpenseCategoryInteractor implements UpdateExpenseCategoryUseCase {
  @override
  Future<ExceptionOr<Unit>> call(
    UpdateExpenseCategoryInput input,
  ) async {
    final repository = input.repository;

    final currentValue = await repository.retrieveById(
      repoId: input.uid,
      id: input.categoryId,
    );
    final newValue = currentValue.map(
      (value) => value.copyWith(
        name: input.name,
        totalBudget: input.budget,
      ),
    );

    Future<ExceptionOr<Unit>> update(ExpenseCategory value) =>
        repository.update(
          repoId: input.uid,
          newValue: value,
        );
    return newValue.fold(toFutureLeft, update);
  }
}
