import 'package:household_accounts/util/domain/entities/category.dart';

class CategoryModel extends Category {
  CategoryModel.fromIdAndJson(String id, Map<String, Object?> json)
      : super(
          id,
          json['name'] as String,
          RecordTypeParsing.fromShortString(json['type'] as String),
          0, // Budget is not used (currently).
        );

  Map<String, Object?> toJson() => {
        'name': name,
        'type': type.toShortString(),
      };
}
