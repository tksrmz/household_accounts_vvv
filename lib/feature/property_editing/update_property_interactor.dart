import 'package:dartz/dartz.dart';

import '../../entity/property.dart';
import '../../util/method/future_either.dart';
import '../../util/type/exception_or.dart';
import 'update_property_use_case.dart';

class UpdatePropertyInteractor implements UpdatePropertyUseCase {
  @override
  Future<ExceptionOr<Unit>> call(UpdatePropertyInput input) async {
    final repository = input.repository;

    final failureOrCurrentValue = await repository.retrieveById(
      repoId: input.uid,
      id: input.propertyId,
    );
    final failureOrNewValue = failureOrCurrentValue.map(
      (currentValue) =>
          currentValue.copyWith(name: input.name, amount: input.amount),
    );

    Future<ExceptionOr<Unit>> update(Property value) =>
        repository.update(repoId: input.uid, newValue: value);

    return failureOrNewValue.fold(toFutureLeft, update);
  }
}
