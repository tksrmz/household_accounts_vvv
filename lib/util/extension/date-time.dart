extension MonthCalculation on DateTime {
  DateTime nextMonth() => DateTime(this.year, this.month + 1);
}

extension DateModifier on DateTime {
  DateTime toFirstDayOfMonth() => DateTime(this.year, this.month);
}
