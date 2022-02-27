import 'package:household_accounts/util/domain/entities/category.dart';

class CategoryModel extends Category {
  CategoryModel.fromJson(Map<String, Object?> json)
      : super(
          json['id'] as String,
          json['name'] as String,
          RecordTypeParsing.fromShortString(json['type'] as String),
          0, // Budget is not used (currently).
        );

  Map<String, Object?> toJson() =>
      {
        'id': id,
        'name': name,
        'type': type.toShortString()};
}
