import 'package:freezed_annotation/freezed_annotation.dart';

part 'property_amount.freezed.dart';

/// 資産額
@freezed
abstract class PropertyAmountVo with _$PropertyAmountVo {
  const factory PropertyAmountVo(int value) = _PropertyAmountVo;

  const PropertyAmountVo._();
}