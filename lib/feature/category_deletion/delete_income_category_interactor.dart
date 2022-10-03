import 'package:dartz/dartz.dart';

import '../../util/type/exception_or.dart';
import 'delete_income_category_use_case.dart';

class DeleteIncomeCategoryInteractor implements DeleteIncomeCategoryUseCase {
  @override
  Future<ExceptionOr<Unit>> call(DeleteIncomeCategoryInput input) {
    final repository = input.repository;
    return repository.deleteById(
      repoId: input.uid,
      id: input.categoryId,
    );
  }
}
