import 'package:household_accounts/entity/property.dart';
import 'package:household_accounts/use_case/uc_repository.dart';

class InMemoryPropertyRepository implements PropertyRepository {
  final _repository = <Property>[
    Property('Cash', 100),
    Property('Bank', 200),
  ];

  @override
  Future<List<Property>> retrieveProperties() async {
    return [..._repository];
  }
}
