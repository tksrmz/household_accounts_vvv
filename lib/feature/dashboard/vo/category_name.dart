import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_name.freezed.dart';

@freezed
class CategoryName with _$CategoryName {
  @Assert('value.length > 0 && value.length <= CategoryName.maxNameLength',
      'Category name must be between 1 and ${CategoryName.maxNameLength} characters.')
  const factory CategoryName(String value) = _CategoryName;

  /// Maximum characters in the name of a category.
  static const int maxNameLength = 20;
}
