import 'package:dartz/dartz.dart';

import '../../util/type/exception_or.dart';
import 'delete_expense_category_use_case.dart';

class DeleteExpenseCategoryInteractor implements DeleteExpenseCategoryUseCase {
  @override
  Future<ExceptionOr<Unit>> call(DeleteExpenseCategoryInput input) {
    final repository = input.repository;
    return repository.deleteById(
      repoId: input.uid,
      id: input.categoryId,
    );
  }
}
