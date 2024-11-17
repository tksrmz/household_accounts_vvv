/// Date that will be used in the dashboard.
/// This is consisted of year, month and day.
class Date {
  /// Create a new date that represents today.
  Date.today() : _dateTime = DateTime.now();

  /// Create a new date with the given year, month and day.
  Date(int year, int month, int day) : _dateTime = DateTime(year, month, day);

  // Use DateTime instead of implementing by myself.
  final DateTime _dateTime;

  /// Get the year of this date.
  int get year => _dateTime.year;

  /// Get the month of this date.
  int get month => _dateTime.month;

  /// Get the day of this date.
  int get day => _dateTime.day;
}
