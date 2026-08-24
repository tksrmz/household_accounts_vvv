import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../domain/models/amount.dart';
import '../../../domain/models/category_id.dart';
import '../../../domain/models/property_id.dart';
import '../../../domain/models/record.dart';
import '../../../domain/models/record_date.dart';
import '../../../domain/models/record_id.dart';
import '../../../domain/models/record_note.dart';

// incomes/expensesのFirestoreドキュメントは形が同一(date/amount/note/property/
// category)だが、収入と支出はドメイン的に別物であるため、DTOクラスを共用しない。
// 共用すると、変換結果がIncomeRecordなのかExpenseRecordなのかを呼び出し側が
// 別途管理する必要が生まれてしまう。

/// incomesコレクションの1ドキュメントを表すDTO。
class IncomeRecordDto {
  IncomeRecordDto({
    required this.id,
    required this.date,
    required this.amount,
    required this.note,
    required this.categoryId,
    required this.propertyId,
  });

  /// [doc]から[IncomeRecordDto]を組み立てる。
  ///
  /// フィールドの欠損・型不正のときは[FormatException]を送出する。
  factory IncomeRecordDto.fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return IncomeRecordDto(
      id: doc.id,
      date: _readDate(data, doc.id),
      amount: _readAmount(data, doc.id),
      note: _readNote(data, doc.id),
      categoryId: _readRefId(data, 'category', doc.id),
      propertyId: _readRefId(data, 'property', doc.id),
    );
  }

  final String id;
  final DateTime date;
  final int amount;
  final String note;
  final String categoryId;
  final String propertyId;

  /// ドメインモデルへ変換する。値型([Amount]/[RecordNote]等)の検証違反による
  /// [FormatException]はそのまま透過させる。
  Record toDomain() => Record.income(
    id: RecordId(id),
    date: RecordDate(date),
    amount: Amount(amount),
    note: RecordNote(note),
    categoryId: CategoryId(categoryId),
    propertyId: PropertyId(propertyId),
  );
}

/// expensesコレクションの1ドキュメントを表すDTO。
class ExpenseRecordDto {
  ExpenseRecordDto({
    required this.id,
    required this.date,
    required this.amount,
    required this.note,
    required this.categoryId,
    required this.propertyId,
  });

  /// [doc]から[ExpenseRecordDto]を組み立てる。
  ///
  /// フィールドの欠損・型不正のときは[FormatException]を送出する。
  factory ExpenseRecordDto.fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return ExpenseRecordDto(
      id: doc.id,
      date: _readDate(data, doc.id),
      amount: _readAmount(data, doc.id),
      note: _readNote(data, doc.id),
      categoryId: _readRefId(data, 'category', doc.id),
      propertyId: _readRefId(data, 'property', doc.id),
    );
  }

  final String id;
  final DateTime date;
  final int amount;
  final String note;
  final String categoryId;
  final String propertyId;

  /// ドメインモデルへ変換する。値型([Amount]/[RecordNote]等)の検証違反による
  /// [FormatException]はそのまま透過させる。
  Record toDomain() => Record.expense(
    id: RecordId(id),
    date: RecordDate(date),
    amount: Amount(amount),
    note: RecordNote(note),
    categoryId: CategoryId(categoryId),
    propertyId: PropertyId(propertyId),
  );
}

/// transfersコレクションの1ドキュメントを表すDTO。
class TransferRecordDto {
  TransferRecordDto({
    required this.id,
    required this.date,
    required this.amount,
    required this.note,
    required this.fromPropertyId,
    required this.toPropertyId,
  });

  /// [doc]から[TransferRecordDto]を組み立てる。
  ///
  /// フィールドの欠損・型不正のときは[FormatException]を送出する。
  factory TransferRecordDto.fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return TransferRecordDto(
      id: doc.id,
      date: _readDate(data, doc.id),
      amount: _readAmount(data, doc.id),
      note: _readNote(data, doc.id),
      fromPropertyId: _readRefId(data, 'fromProperty', doc.id),
      toPropertyId: _readRefId(data, 'toProperty', doc.id),
    );
  }

  final String id;
  final DateTime date;
  final int amount;
  final String note;
  final String fromPropertyId;
  final String toPropertyId;

  /// ドメインモデルへ変換する。値型([Amount]/[RecordNote]等)の検証違反や、
  /// 振替元と振替先が同一資産であることによる送出([Record.transfer]の
  /// [Assert])はそのまま透過させる。
  Record toDomain() => Record.transfer(
    id: RecordId(id),
    date: RecordDate(date),
    amount: Amount(amount),
    note: RecordNote(note),
    fromPropertyId: PropertyId(fromPropertyId),
    toPropertyId: PropertyId(toPropertyId),
  );
}

DateTime _readDate(Map<String, dynamic> data, String docId) {
  final value = data['date'];
  if (value is! Timestamp) {
    throw FormatException('date フィールドが不正です: docId=$docId');
  }
  return value.toDate();
}

int _readAmount(Map<String, dynamic> data, String docId) {
  final value = data['amount'];
  if (value is! int) {
    throw FormatException('amount フィールドが不正です: docId=$docId');
  }
  return value;
}

String _readNote(Map<String, dynamic> data, String docId) {
  final value = data['note'];
  if (value is! String) {
    throw FormatException('note フィールドが不正です: docId=$docId');
  }
  return value;
}

/// [field]が`{'ref': DocumentReference}`形の参照フィールドであることを検証し、
/// 参照先のドキュメントIDを取り出す。Firestore型([Timestamp]/[DocumentReference])を
/// DTOの外へ漏らさないよう、ここでStringへ変換する。
String _readRefId(Map<String, dynamic> data, String field, String docId) {
  final wrapper = data[field];
  if (wrapper is! Map<String, dynamic>) {
    throw FormatException('$field フィールドが不正です: docId=$docId');
  }
  final ref = wrapper['ref'];
  if (ref is! DocumentReference) {
    throw FormatException('$field.ref フィールドが不正です: docId=$docId');
  }
  return ref.id;
}
