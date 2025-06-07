import 'package:freezed_annotation/freezed_annotation.dart';

import 'vo/category_id.dart';
import 'vo/category_name.dart';

part 'income_category.freezed.dart';

/// 収入カテゴリ
@freezed
abstract class IncomeCategoryVo with _$IncomeCategoryVo {
  const factory IncomeCategoryVo({
    required CategoryIdVo id,
    required CategoryNameVo name,
  }) = _IncomeCategoryVo;

  const IncomeCategoryVo._();

  /// 削除済みカテゴリ
  static final deleted = IncomeCategoryVo(
    id: CategoryIdVo('deleted-income-category'),
    name: CategoryNameVo('削除済み'),
  );
}