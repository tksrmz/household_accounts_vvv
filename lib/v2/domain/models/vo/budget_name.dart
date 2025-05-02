import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget_name.freezed.dart';

@freezed
abstract class BudgetName with _$BudgetName {
  /// 最大の文字数
  static const maxLength = 20;

  @Assert('value.length > 0', '予算名は1文字以上である必要があります')
  @Assert('value.length <= ${maxLength}', '予算名は20文字以下である必要があります')
  const factory BudgetName(String value) = _BudgetName;
}
