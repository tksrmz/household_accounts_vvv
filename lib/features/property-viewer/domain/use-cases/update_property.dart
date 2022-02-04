import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:household_accounts/util/domain/entities/property.dart';
import 'package:household_accounts/features/property-viewer/domain/repositories/property_repository.dart';
import 'package:household_accounts/util/failures/failure.dart';
import 'package:household_accounts/util/use_case.dart';

typedef UpdatePropertyUseCase = UseCase<UpdatePropertyInput, Property>;

class UpdatePropertyInput extends Equatable {
  final String id;
  final String? newPropertyName;
  final int? newPropertyAmount;

  const UpdatePropertyInput({
    required String id,
    String? newPropertyName,
    int? newPropertyAmount,
  })  : this.id = id,
        this.newPropertyName = newPropertyName,
        this.newPropertyAmount = newPropertyAmount;

  @override
  List<Object> get props {
    final props = <Object>[id];
    if (newPropertyName != null) {
      props.add(newPropertyName!);
    }
    if (newPropertyAmount != null) {
      props.add(newPropertyAmount!);
    }
    return props;
  }
}

class UpdatePropertyInteractor extends UpdatePropertyUseCase {
  final PropertyRepository _repository;

  UpdatePropertyInteractor(this._repository);

  @override
  Future<Either<Failure, Property>> handle(UpdatePropertyInput input) async {
    final failureOrCurrentValue = await _repository.retrieveById(input.id);
    final failureOrNewValue = failureOrCurrentValue.map((currentValue) {
      final name = input.newPropertyName ?? currentValue.name;
      final amount = input.newPropertyAmount ?? currentValue.amount;
      return Property(input.id, name, amount);
    });

    return await failureOrNewValue.fold<Future<Either<Failure, Property>>>(
      (failure) async => Left(failure),
      (newValue) async {
        final failureOrSuccess = await _repository.update(newValue);
        return failureOrSuccess.map((_) => newValue);
      },
    );
  }
}
