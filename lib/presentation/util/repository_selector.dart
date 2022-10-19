import '../../entity/property_entity.dart';
import '../../feature/repository/property_repository.dart';
import '../../util/service_locator/main.dart';
import '../../util/type/repository.dart';
import '../../util/type/single_or_pair.dart';

Repository2<Property> selectPropertyRepository(SingleOrPair value) {
  print('$selectPropertyRepository($value)');
  final Repository2<Property> repository;

  switch (value) {
    case SingleOrPair.single:
      print('$selectPropertyRepository: Select personal repository.');
      repository = sl<PersonalPropertyRepository>();
      break;

    case SingleOrPair.pair:
      print('$selectPropertyRepository: Select shared repository.');
      repository = sl<SharedPropertyRepository>();
      break;
  }

  return repository;
}
