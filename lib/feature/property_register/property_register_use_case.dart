import 'package:equatable/equatable.dart';
import 'package:household_accounts/entity/property_entity.dart';
import 'package:household_accounts/feature/repository/property_repository.dart';
import 'package:household_accounts/util/type/use_case.dart';
import 'package:household_accounts/util/uuid/uuid.dart';

import '../../util/type/exception_or.dart';

typedef AddPropertiesUseCase = UseCase2<AddPropertyInput, Property>;

@deprecated
class AddPropertyInput extends Equatable {
  final String propertyName;
  final int initialAmount;

  AddPropertyInput(this.propertyName, this.initialAmount);

  @override
  List<Object> get props => [propertyName, initialAmount];
}

@deprecated
class AddPropertyInteractor extends AddPropertiesUseCase {
  final PropertyRepository _repository;

  AddPropertyInteractor(this._repository);

  @override
  Future<ExceptionOr<Property>> call(AddPropertyInput input) async {
    final property = Property(
      UUID.generate(),
      input.propertyName,
      input.initialAmount,
    );
    final result = await _repository.register(property);
    return result.replace<Property>(property);
  }
}

typedef AddPersonalPropertyUseCase
    = UseCase2<AddPersonalPropertyInput, Property>;

class AddPersonalPropertyInput {
  /// User ID.
  final String uid;

  /// Name of new property.
  final String name;

  /// Amount of new property.
  final int amount;

  AddPersonalPropertyInput({
    required this.uid,
    required this.name,
    required this.amount,
  });
}

class AddPersonalPropertyInteractor implements AddPersonalPropertyUseCase {
  final PropertyRepository2 _repository;

  AddPersonalPropertyInteractor(this._repository);

  @override
  Future<ExceptionOr<Property>> call(AddPersonalPropertyInput input) async {
    final property = Property(
      UUID.generate(),
      input.name,
      input.amount,
    );
    final result = await _repository.register(
      repoId: input.uid,
      value: property,
    );
    return result.replace<Property>(property);
  }
}

typedef AddSharedPropertyUseCase = UseCase2<AddSharedPropertyInput, Property>;

class AddSharedPropertyInput {
  /// Pair ID.
  final String pairId;

  /// Name of new property.
  final String name;

  /// Amount of new property.
  final int amount;

  AddSharedPropertyInput({
    required this.pairId,
    required this.name,
    required this.amount,
  });
}

class AddSharedPropertyInteractor implements AddSharedPropertyUseCase {
  final PropertyRepository2 _repository;

  AddSharedPropertyInteractor(this._repository);

  @override
  Future<ExceptionOr<Property>> call(AddSharedPropertyInput input) async {
    final property = Property(
      UUID.generate(),
      input.name,
      input.amount,
    );
    final result = await _repository.register(
      repoId: input.pairId,
      value: property,
    );
    return result.replace<Property>(property);
  }
}
