import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:household_accounts/entity/property.dart';
import 'package:household_accounts/use_case/uc_repository.dart';

class InMemoryPropertyRepository implements PropertyRepository {
  final _repository = <Property>[
    Property('id1', 'Cash', 100),
    Property('id2', 'Bank', 200),
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

class FirebasePropertyRepository implements PropertyRepository {
  final _propertiesRef = FirebaseFirestore.instance
      .collection('properties')
      .withConverter<Property>(
        fromFirestore: (snapshot, _) {
          final id = snapshot.id;
          final json = snapshot.data()!;
          return Property.fromIdAndJson(id, json);
        },
        toFirestore: (record, _) => record.toJson(),
      );

  @override
  Future<List<Property>> retrieveProperties() async {
    return _propertiesRef
        .get()
        .then((snapshot) => snapshot.docs)
        .then((properties) => List.of(properties.map((e) => e.data())));
  }

  @override
  Future<void> updateProperty(Property newValue) async {
    _propertiesRef
        .doc(newValue.id)
        .update({'name': newValue.name, 'amount': newValue.amount});
  }
}
