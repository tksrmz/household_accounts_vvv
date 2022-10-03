import 'package:dartz/dartz.dart';

import '../../entity/category_entity.dart';
import '../../util/method/future_either.dart';
import '../../util/type/exception_or.dart';
import 'update_income_category_use_case.dart';

class UpdateIncomeCategoryInteractor implements UpdateIncomeCategoryUseCase {
  @override
  Future<ExceptionOr<Unit>> call(
    UpdateIncomeCategoryInput input,
  ) async {
    final repository = input.repository;

    final currentValue = await repository.retrieveById(
      repoId: input.uid,
      id: input.categoryId,
    );
    final newValue = currentValue.map(
      (value) => value.copyWith(
        name: input.name,
      ),
    );

    final update = (IncomeCategory value) => repository.update(
          repoId: input.uid,
          newValue: value,
        );
    return newValue.fold(toFutureLeft, update);
  }
}
