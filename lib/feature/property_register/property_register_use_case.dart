import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:household_accounts/entity/property_entity.dart';
import 'package:household_accounts/feature/repository/property_repository.dart';
import 'package:household_accounts/util/type/failure.dart';
import 'package:household_accounts/util/type/use_case.dart';
import 'package:household_accounts/util/uuid/uuid.dart';

typedef AddPropertiesUseCase = UseCase<AddPropertyInput, Property>;

class AddPropertyInput extends Equatable {
  final String propertyName;
  final int initialAmount;

  AddPropertyInput(this.propertyName, this.initialAmount);

  @override
  List<Object> get props => [propertyName, initialAmount];
}

class AddPropertyInteractor extends AddPropertiesUseCase {
  final PropertyRepository _repository;

  AddPropertyInteractor(this._repository);

  @override
  Future<Either<Failure, Property>> handle(AddPropertyInput input) async {
    final property = Property(
      UUID.generate(),
      input.propertyName,
      input.initialAmount,
    );
    final result = await _repository.register(property);
    return result.replace<Property>(property);
  }
}
