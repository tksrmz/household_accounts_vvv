import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../domain/models/amount.dart';
import '../../../domain/models/category_id.dart';
import '../../../domain/models/property_id.dart';
import '../../../domain/models/record.dart';
import '../../../domain/models/record_content.dart';
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
  /// フィールドの欠損・型不正、および`type`フィールドが`income`でないときは
  /// [FormatException]を送出する。
  factory IncomeRecordDto.fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) => IncomeRecordDto.fromData(doc.id, doc.data());

  /// ドキュメントID[docId]と中身[data]から[IncomeRecordDto]を組み立てる。
  ///
  /// フィールドの欠損・型不正、および`type`フィールドが`income`でないときは
  /// [FormatException]を送出する。
  factory IncomeRecordDto.fromData(String docId, Map<String, dynamic> data) {
    _requireType(data, 'income', docId);
    return IncomeRecordDto(
      id: docId,
      date: _readDate(data, docId),
      amount: _readAmount(data, docId),
      note: _readNote(data, docId),
      categoryId: _readRefId(data, 'category', docId),
      propertyId: _readRefId(data, 'property', docId),
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
  /// フィールドの欠損・型不正、および`type`フィールドが`expense`でないときは
  /// [FormatException]を送出する。
  factory ExpenseRecordDto.fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) => ExpenseRecordDto.fromData(doc.id, doc.data());

  /// ドキュメントID[docId]と中身[data]から[ExpenseRecordDto]を組み立てる。
  ///
  /// フィールドの欠損・型不正、および`type`フィールドが`expense`でないときは
  /// [FormatException]を送出する。
  factory ExpenseRecordDto.fromData(String docId, Map<String, dynamic> data) {
    _requireType(data, 'expense', docId);
    return ExpenseRecordDto(
      id: docId,
      date: _readDate(data, docId),
      amount: _readAmount(data, docId),
      note: _readNote(data, docId),
      categoryId: _readRefId(data, 'category', docId),
      propertyId: _readRefId(data, 'property', docId),
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
  /// フィールドの欠損・型不正、および`type`フィールドが`transfer`でないときは
  /// [FormatException]を送出する。
  factory TransferRecordDto.fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) => TransferRecordDto.fromData(doc.id, doc.data());

  /// ドキュメントID[docId]と中身[data]から[TransferRecordDto]を組み立てる。
  ///
  /// フィールドの欠損・型不正、および`type`フィールドが`transfer`でないときは
  /// [FormatException]を送出する。
  factory TransferRecordDto.fromData(String docId, Map<String, dynamic> data) {
    _requireType(data, 'transfer', docId);
    return TransferRecordDto(
      id: docId,
      date: _readDate(data, docId),
      amount: _readAmount(data, docId),
      note: _readNote(data, docId),
      fromPropertyId: _readRefId(data, 'fromProperty', docId),
      toPropertyId: _readRefId(data, 'toProperty', docId),
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

/// レコード種別(`type`フィールド)が[expected]と一致することを検証する。
///
/// コレクションの所属だけで種別を決めると、誤った場所に置かれた
/// ドキュメントを黙って別種別として集計してしまうため、
/// ドキュメント自身が宣言する種別と突き合わせる。
void _requireType(Map<String, dynamic> data, String expected, String docId) {
  final value = data['type'];
  if (value != expected) {
    throw FormatException('type フィールドが不正です(期待: $expected): docId=$docId');
  }
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

// 書き込み用のDTOは上記の読み取り用クラスとは形が異なる(読み取りはidを持ち
// 参照はString化済み、書き込みはidを持たずFirestoreの生の型
// (DocumentReference/serverTimestampのセンチネル)をそのまま使う)ため、
// クラスを共用せずトップレベル関数として分けて表現する。

/// incomesコレクションへ書き込むJSONを組み立てる。
///
/// Firestore Rulesが要求する8フィールド版スキーマ
/// (date/amount/note/createdAt/hasCheckedOut/type/category/property)の
/// キー集合と完全に一致させる必要がある。
Map<String, Object?> incomeRecordJson({
  required IncomeRecordContent record,
  required DocumentReference<Map<String, dynamic>> categoryRef,
  required DocumentReference<Map<String, dynamic>> propertyRef,
}) => {
  ..._commonRecordJson(record),
  'type': 'income',
  'category': {'ref': categoryRef},
  'property': {'ref': propertyRef},
};

/// expensesコレクションへ書き込むJSONを組み立てる。
///
/// Firestore Rulesが要求する8フィールド版スキーマの
/// キー集合と完全に一致させる必要がある。
Map<String, Object?> expenseRecordJson({
  required ExpenseRecordContent record,
  required DocumentReference<Map<String, dynamic>> categoryRef,
  required DocumentReference<Map<String, dynamic>> propertyRef,
}) => {
  ..._commonRecordJson(record),
  'type': 'expense',
  'category': {'ref': categoryRef},
  'property': {'ref': propertyRef},
};

/// transfersコレクションへ書き込むJSONを組み立てる。
///
/// Firestore Rulesが要求する8フィールド版スキーマ(category/propertyの代わりに
/// fromProperty/toPropertyを持つ)のキー集合と完全に一致させる必要がある。
Map<String, Object?> transferRecordJson({
  required TransferRecordContent record,
  required DocumentReference<Map<String, dynamic>> fromPropertyRef,
  required DocumentReference<Map<String, dynamic>> toPropertyRef,
}) => {
  ..._commonRecordJson(record),
  'type': 'transfer',
  'fromProperty': {'ref': fromPropertyRef},
  'toProperty': {'ref': toPropertyRef},
};

/// 収入/支出/振替に共通するフィールドを組み立てる。
///
/// `createdAt`はクライアント時計ではなくサーバー時刻のセンチネル
/// ([FieldValue.serverTimestamp])を書く(Firestore Rulesが
/// `createdAt == request.time`を要求するため)。`hasCheckedOut`は常にtrueを書く
/// (このRepositoryが作成するレコードは作成と同時に残高へ反映済みであることを
/// 表すフラグであり、カレンダーの削除処理がこのフラグを見て残高打ち消しの
/// 要否を決めるため)。
Map<String, Object?> _commonRecordJson(RecordContent record) => {
  'date': Timestamp.fromDate(record.date.value),
  'amount': record.amount.value,
  'note': record.note.value,
  'createdAt': FieldValue.serverTimestamp(),
  'hasCheckedOut': true,
};
