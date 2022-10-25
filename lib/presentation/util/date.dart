import 'package:flutter/material.dart';

DateTime addMonths(int year, int month, int delta) =>
    DateUtils.addMonthsToMonthDate(
      DateTime(year, month),
      delta,
    );

bool isCurrentMonth(int year, int month) {
  final date = DateTime(year, month);
  return DateUtils.isSameMonth(date, DateTime.now());
}
