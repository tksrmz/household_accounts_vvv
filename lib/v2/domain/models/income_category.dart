import 'package:freezed_annotation/freezed_annotation.dart';

import 'vo/category_id.dart';
import 'vo/category_name.dart';

part 'income_category.freezed.dart';

/// 収入カテゴリ
@freezed
abstract class IncomeCategoryModel with _$IncomeCategoryModel {
  const factory IncomeCategoryModel({
    required CategoryIdVo id,
    required CategoryNameVo name,
  }) = _IncomeCategoryModel;

  const IncomeCategoryModel._();

  /// 削除済みカテゴリ
  static const deleted = IncomeCategoryModel(
    id: CategoryIdVo('deleted-income-category'),
    name: CategoryNameVo('削除済み'),
  );
}
