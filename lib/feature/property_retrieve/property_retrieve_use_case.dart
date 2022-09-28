import '../../entity/property_entity.dart';
import '../../util/type/use_case.dart';

typedef RetrievePersonalPropertiesUseCase
    = UseCase2<RetrievePersonalPropertiesInput, List<Property>>;

class RetrievePersonalPropertiesInput {
  /// User ID.
  final String uid;

  RetrievePersonalPropertiesInput({
    required this.uid,
  });
}

typedef RetrieveSharedPropertiesUseCase
    = UseCase2<RetrieveSharedPropertiesInput, List<Property>>;

class RetrieveSharedPropertiesInput {
  /// Pair ID.
  final String pairId;

  RetrieveSharedPropertiesInput({
    required this.pairId,
  });
}
