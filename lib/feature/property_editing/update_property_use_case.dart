import 'package:dartz/dartz.dart';

import '../../entity/property_entity.dart';
import '../../util/type/repository.dart';
import '../../util/type/use_case.dart';

typedef UpdatePropertyUseCase = UseCase2<UpdatePropertyInput, Unit>;

class UpdatePropertyInput {
  /// User ID or pair ID.
  final String uid;

  /// ID of the property to be updated.
  final String propertyId;

  /// New property name.
  ///
  /// If this value is null, the property name will not change.
  final String? name;

  /// New property amount.
  ///
  /// If this value is null, the property amount will not change.
  final int? amount;

  /// Repository where the target property exists.
  final Repository2<Property> repository;

  const UpdatePropertyInput({
    required this.uid,
    required this.propertyId,
    this.name,
    this.amount,
    required this.repository,
  });
}
