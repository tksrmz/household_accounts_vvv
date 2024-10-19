import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'amount.freezed.dart';

@freezed
class Amount with _$Amount {
  const factory Amount(int value) = _Amount;

  const Amount._();

  operator -(Amount other) {
    return Amount(value - other.value);
  }
}
