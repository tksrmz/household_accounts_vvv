import '../../entity/property.dart';
import '../../util/type/json.dart';
import 'data_model.dart';

class PropertyModel implements DataModel<Property> {
  PropertyModel.fromEntity(Property property)
      : id = property.id,
        name = property.name,
        amount = property.amount;

  PropertyModel.fromJson(Json json)
      : id = json['id'] as String,
        name = json['name'] as String,
        amount = json['amount'] as int;

  final String id;
  final String name;
  final int amount;

  @override
  Property toEntity() => Property(
        id,
        name,
        amount,
      );

  @override
  Json toJson() => {
        'name': name,
        'amount': amount,
      };
}
