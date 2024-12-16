import '../../entity/property.dart';
import '../../util/type/repository.dart';
import '../../util/type/use_case.dart';

typedef RetrievePropertiesUseCase
    = UseCase<RetrievePropertiesInput, List<Property>>;

class RetrievePropertiesInput {
  /// User ID or pair ID.
  final String uid;

  /// Repository from which retrieve properties.
  final Repository<Property> repository;

  RetrievePropertiesInput({
    required this.uid,
    required this.repository,
  });

  @override
  String toString() => '$RetrievePropertiesInput($uid, $repository)';
}
