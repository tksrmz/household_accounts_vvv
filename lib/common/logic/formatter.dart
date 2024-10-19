import 'package:intl/intl.dart';

abstract class Formatter {
  /// Format the given [date] to a string.
  static String date(DateTime date) => DateFormat.yMMMEd().format(date);

  /// Format the given [value] to a simple currency string.
  static String simpleCurrency(int value) =>
      NumberFormat.simpleCurrency(name: 'JPY').format(value.toDouble());
}
