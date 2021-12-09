import 'package:cloud_firestore/cloud_firestore.dart';

class Record {
  final DateTime   dateOfInput;
  final DateTime   dateOfRecord;
  final int        amount;
  final RecordType recordType;
  final String     note;
  final String     category;

  Record(this.dateOfInput, this.dateOfRecord, this.amount, this.recordType, this.note, this.category);

  Record.fromJson(Map<String, Object?> json)
    : this(
    (json['editedAt'] as Timestamp).toDate(),
    (json['tradingDate'] as Timestamp).toDate(),
    json['amount'] as int,
    json['recordType'] as RecordType, // ここもどうにかする必要がある
    json['note'] as String,
    json['category'] as String,
  );

  Map<String, Object?> toJson() {
    return {
      // 'editedAt': 1,
      // 'tradingDate': 1,
      'editedAt': Timestamp.fromDate(dateOfInput),
      'tradingDate': Timestamp.fromDate(dateOfRecord),
      'amount': amount,
      'recordType': recordType.toShortString(),
      'note': note,
      'category': category,
    };
  }
}

enum RecordType {
  expense,
  income,
}

extension RecordTypeParsing on RecordType {
  String toShortString() => this.toString().split('.').last;
}

final incomeCategories = [
  "Salary",
  "Pocket money",
  "Others",
];

final expenseCategories = [
  "Food",
  "Transportation",
  "Household things",
  "Entertainment",
  "Others",
];
