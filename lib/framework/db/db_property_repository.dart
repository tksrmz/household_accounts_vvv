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

  @override
  Future<void> updateProperty(Property newValue) async {
    final index =
        _repository.indexWhere((element) => element.name == newValue.name);

    if (index != -1) {
      _repository[index].amount = newValue.amount;
    }
  }
}
