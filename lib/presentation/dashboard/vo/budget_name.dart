import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget_name.freezed.dart';

// @freezed
// class BudgetName with _$BudgetName {
//   const factory BudgetName({
//     required String value,
//   }) = _BudgetName;
// }
// This file is "main.dart"

@freezed
class Person with _$Person {
  const factory Person({
    required String firstName,
    required String lastName,
    required int age,
  }) = _Person;
}
