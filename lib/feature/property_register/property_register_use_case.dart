import 'package:dartz/dartz.dart';

import '../../entity/property_entity.dart';
import '../../util/type/repository.dart';
import '../../util/type/use_case.dart';

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
