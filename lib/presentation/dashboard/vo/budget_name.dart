import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget_name.freezed.dart';

@freezed
class BudgetName with _$BudgetName {
  /// 最大の文字数
  static const _maxLength = 20;

  @Assert('value.isNotEmpty', '予算名は1文字以上である必要があります')
  @Assert('value.length <= ${_maxLength}', '予算名は20文字以下である必要があります')
  factory BudgetName(String value) = _BudgetName;
}
