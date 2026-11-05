import 'package:freezed_annotation/freezed_annotation.dart';

import 'property_id.dart';
import 'property_name.dart';

part 'property.freezed.dart';

/// 資産。
///
/// [balance]は残高。支出で負になりうるうえ、取りうる値に検証がないため
/// 値型でラップしない(金額>0の`Amount`とは別物)。
@freezed
abstract class Property with _$Property {
  const factory Property({
    required PropertyId id,
    required PropertyName name,
    required int balance,
  }) = _Property;
}
