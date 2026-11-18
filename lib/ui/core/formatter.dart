import 'package:intl/intl.dart';

abstract class Formatter {
  /// Format the given [value] to a simple currency string.
  static String simpleCurrency(int value) =>
      NumberFormat.simpleCurrency(name: 'JPY').format(value.toDouble());
}
