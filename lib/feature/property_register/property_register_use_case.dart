import 'package:dartz/dartz.dart';

import '../../entity/property_entity.dart';
import '../../util/type/exception_or.dart';
import '../../util/type/repository.dart';
import '../../util/type/use_case.dart';
import '../../util/uuid/uuid.dart';
import '../repository/property_repository.dart';

typedef AddPersonalPropertyUseCase
    = UseCase2<AddPersonalPropertyInput, Property>;

@deprecated
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

@deprecated
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

@deprecated
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

@deprecated
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

typedef AddPropertyUseCase = UseCase2<AddPropertyInput, Unit>;

class AddPropertyInput {
  /// User ID or pair ID.
  final String uid;

  /// Name of new property.
  final String name;

  /// Amount of new property.
  final int amount;

  /// Repository where the new property is registered.
  final Repository2<Property> repository;

  AddPropertyInput({
    required this.uid,
    required this.name,
    required this.amount,
    required this.repository,
  });
}
