import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_name.freezed.dart';

/// カテゴリ名
@freezed
abstract class CategoryNameVo with _$CategoryNameVo {
  @Assert('value.length > 0 && value.length <= 20', 'カテゴリ名は1-20文字でなければなりません')
  const factory CategoryNameVo(String value) = _CategoryNameVo;

  const CategoryNameVo._();
}
