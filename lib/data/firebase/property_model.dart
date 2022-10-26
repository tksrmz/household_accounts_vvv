import 'package:household_accounts/entity/property_entity.dart';

import '../../util/type/json.dart';

class PropertyModel extends Property {
  PropertyModel.fromProperty(Property property)
      : super(
          property.id,
          property.name,
          property.amount,
        );

  PropertyModel.fromJson(Json json)
      : super(
          json['id'] as String,
          json['name'] as String,
          json['amount'] as int,
        );

  Json toJson() => {
        'name': name,
        'amount': amount,
      };
}
