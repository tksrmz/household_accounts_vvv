import '../../entity/property_entity.dart';
import '../../util/type/repository.dart';
import '../../util/type/use_case.dart';

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

  @override
  String toString() => '$RetrievePropertiesInput($uid, $repository)';
}
