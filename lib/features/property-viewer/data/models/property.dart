import 'package:household_accounts/util/domain/entities/property.dart';

class PropertyModel extends Property {
  PropertyModel.fromProperty(Property property)
      : super(
          property.id,
          property.name,
          property.amount,
        );

  PropertyModel.fromJson(Map<String, Object?> json)
      : super(
          json['id'] as String,
          json['name'] as String,
          json['amount'] as int,
        );

  PropertyModel.fromIdAndJson(String id, Map<String, Object?> json)
      : super(
          id,
          json['name'] as String,
          json['amount'] as int,
        );

  Map<String, Object?> toJson() => {
        'name': name,
        'amount': amount,
      };
}
