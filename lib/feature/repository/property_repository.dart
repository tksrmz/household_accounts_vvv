import '../../entity/property_entity.dart';
import '../../util/type/repository.dart';

typedef PropertyRepository2 = Repository2<Property>;

abstract class PersonalPropertyRepository extends Repository2<Property> {}

abstract class SharedPropertyRepository extends Repository2<Property> {}
