import '../../entity/property_entity.dart';
import '../../util/type/repository.dart';
import '../../util/type/use_case.dart';

typedef RetrievePersonalPropertiesUseCase
    = UseCase2<RetrievePersonalPropertiesInput, List<Property>>;

@deprecated
class RetrievePersonalPropertiesInput {
  /// User ID.
  final String uid;

  RetrievePersonalPropertiesInput({
    required this.uid,
  });
}

typedef RetrieveSharedPropertiesUseCase
    = UseCase2<RetrieveSharedPropertiesInput, List<Property>>;

@deprecated
class RetrieveSharedPropertiesInput {
  /// Pair ID.
  final String pairId;

  RetrieveSharedPropertiesInput({
    required this.pairId,
  });
}

typedef RetrievePropertiesUseCase
    = UseCase2<RetrievePropertiesInput, List<Property>>;

class RetrievePropertiesInput {
  /// User ID or pair ID.
  final String uid;

  /// Repository from which retrieve properties.
  final Repository2<Property> repository;

  RetrievePropertiesInput({
    required this.uid,
    required this.repository,
  });
}
