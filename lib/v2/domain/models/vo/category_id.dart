import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_id.freezed.dart';

/// カテゴリID
@freezed
abstract class CategoryIdVo with _$CategoryIdVo {
  @Assert('value.length > 0', 'カテゴリIDは空にできません')
  const factory CategoryIdVo(String value) = _CategoryIdVo;

  const CategoryIdVo._();
}