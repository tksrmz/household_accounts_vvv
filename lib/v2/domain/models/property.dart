import 'package:freezed_annotation/freezed_annotation.dart';

import 'vo/property_amount.dart';
import 'vo/property_id.dart';
import 'vo/property_name.dart';

part 'property.freezed.dart';

/// 資産
@freezed
abstract class PropertyVo with _$PropertyVo {
  const factory PropertyVo({
    required PropertyIdVo id,
    required PropertyNameVo name,
    required PropertyAmountVo amount,
  }) = _PropertyVo;

  const PropertyVo._();

  /// 削除済み資産
  static final deleted = PropertyVo(
    id: PropertyIdVo('deleted-property'),
    name: PropertyNameVo('削除済み'),
    amount: PropertyAmountVo(0),
  );
}