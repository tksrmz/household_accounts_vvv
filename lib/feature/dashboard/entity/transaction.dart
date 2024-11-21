import 'date.dart';

abstract interface class Transaction {
  Date get date;
  String get categoryName;
  String get fundInfo;
  String get note;
  int get amount;
}
