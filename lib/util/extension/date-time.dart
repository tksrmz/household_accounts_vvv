extension MonthCalculation on DateTime {
  DateTime nextMonth() => this.month == DateTime.december
      ? DateTime(this.year + 1, DateTime.january)
      : DateTime(this.year, this.month + 1);
}
