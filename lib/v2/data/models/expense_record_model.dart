import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense_record_model.freezed.dart';

@freezed
abstract class ExpenseRecordModel with _$ExpenseRecordModel {
  /// ExpenseRecordModelのコンストラクタ
  ///
  /// テストコードでのみ使用すること。
  /// プロダクションコードでは ExpenseRecordModel.fromJson() を使用する。
  const factory ExpenseRecordModel({
    required String id,
    required DateTime date,
    required int amount,
    required String note,
    required bool hasCheckedOut,
    required DateTime createdAt,
    required Map<String, dynamic> property,
    required Map<String, dynamic> category,
    @Default('expense') String type,
  }) = _ExpenseRecordModel;

  /// Firestoreからの標準的なJSON変換 - Timestampの変換を処理
  factory ExpenseRecordModel.fromJson(Map<String, dynamic> json) {
    // typeの検証
    if (!json.containsKey('type')) {
      throw ArgumentError('ExpenseRecordModel requires "type" field in JSON');
    }
    final type = json['type'] as String;
    if (type != 'expense') {
      throw ArgumentError(
        'ExpenseRecordModel requires type "expense", but got "$type"',
      );
    }
    // createdAtの型変換処理
    Timestamp createdAtTimestamp = json['createdAt'] as Timestamp;
    DateTime createdAt = createdAtTimestamp.toDate();

    // dateの型変換処理
    Timestamp dateTimestamp = json['date'] as Timestamp;
    DateTime date = dateTimestamp.toDate();

    return ExpenseRecordModel(
      id: json['id'] as String,
      date: date,
      amount: json['amount'] as int,
      note: json['note'] as String,
      hasCheckedOut: (json['hasCheckedOut'] ?? true) as bool,
      createdAt: createdAt,
      property: json['property'] as Map<String, dynamic>,
      category: json['category'] as Map<String, dynamic>,
      type: type,
    );
  }
}

extension ExpenseRecordModelFirestore on ExpenseRecordModel {
  /// Firestoreに保存するためのJSONに変換
  /// idは除外（FirestoreのドキュメントIDとして使用されるため）
  Map<String, dynamic> toFirestoreJson() {
    return {
      'date': date,
      'amount': amount,
      'note': note,
      'hasCheckedOut': hasCheckedOut,
      'createdAt': createdAt,
      'property': property,
      'category': category,
      'type': type,
    };
  }
}
