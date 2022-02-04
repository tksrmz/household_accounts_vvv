import 'package:household_accounts/util/domain/entities/property.dart';

class PropertyModel extends Property {
  PropertyModel.fromJson(Map<String, Object?> json)
      : super(
          json['id'] as String,
          json['name'] as String,
          json['amount'] as int,
        );

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
      };
}
