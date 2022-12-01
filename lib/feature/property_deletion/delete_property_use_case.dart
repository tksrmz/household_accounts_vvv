import 'package:dartz/dartz.dart';

import '../../entity/property_entity.dart';
import '../../util/type/repository.dart';
import '../../util/type/use_case.dart';

typedef DeletePropertyUseCase = UseCase<DeletePropertyInput, Unit>;

class DeletePropertyInput {
  /// User ID or pair ID.
  final String uid;

  /// ID of the property to be deleted.
  final String propertyId;

  /// Repository from which delete the property.
  final Repository<Property> repository;

  DeletePropertyInput({
    required this.uid,
    required this.propertyId,
    required this.repository,
  });
}
