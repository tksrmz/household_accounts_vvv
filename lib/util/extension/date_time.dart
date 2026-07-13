extension MonthCalculation on DateTime {
  DateTime nextMonth() => DateTime(year, month + 1);
}

extension DateModifier on DateTime {
  DateTime toFirstDayOfMonth() => DateTime(year, month);
}
