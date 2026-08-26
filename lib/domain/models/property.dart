import 'package:freezed_annotation/freezed_annotation.dart';

import 'property_id.dart';

part 'property.freezed.dart';

/// 資産。
///
/// 記録入力(資産選択)が必要とする最小限のフィールドのみを持つ。残高(amount)は
/// 資産管理画面の移行時に追加する(この画面の移行時点では資産を選択できれば
/// 十分なため)。
@freezed
abstract class Property with _$Property {
  const factory Property({required PropertyId id, required String name}) =
      _Property;
}
