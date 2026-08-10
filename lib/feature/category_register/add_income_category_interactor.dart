import 'package:dartz/dartz.dart';

import '../../entity/category.dart';
import '../../util/type/exception_or.dart';
import '../../util/uuid/uuid.dart';
import 'add_income_category_use_case.dart';

class AddIncomeCategoryInteractor implements AddIncomeCategoryUseCase {
  @override
  Future<ExceptionOr<Unit>> call(AddIncomeCategoryInput input) {
    final repository = input.repository;

    final category = IncomeCategory(id: UUID.generate(), name: input.name);
    return repository.register(repoId: input.uid, value: category);
  }
}
