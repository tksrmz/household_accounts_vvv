import 'package:household_accounts/features/category-page/domain/entities/category.dart';

class CategoryModel extends Category {
  CategoryModel.fromJson(Map<String, Object?> json)
      : super(
          json['id'] as String,
          json['name'] as String,
          RecordTypeParsing.fromShortString(json['type'] as String),
        );

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'type': type.toShortString(),
      };
}
