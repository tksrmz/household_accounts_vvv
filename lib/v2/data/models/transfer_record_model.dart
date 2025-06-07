import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transfer_record_model.freezed.dart';

@freezed
class TransferRecordModel with _$TransferRecordModel {
  const TransferRecordModel._();

  const factory TransferRecordModel({
    required String id,
    required DateTime date,
    required int amount,
    required String note,
    required bool hasCheckedOut,
    required DateTime createdAt,
    required Map<String, dynamic> fromProperty,
    required Map<String, dynamic> toProperty,
    @Default('transfer') String type,
  }) = _TransferRecordModel;

  /// Firestoreからの標準的なJSON変換 - Timestampの変換を処理
  factory TransferRecordModel.fromFirestoreJson(Map<String, dynamic> json) {
    // createdAtの型変換処理
    dynamic createdAtValue = json['createdAt'];
    DateTime createdAt;
    if (createdAtValue is Timestamp) {
      createdAt = createdAtValue.toDate();
    } else if (createdAtValue is DateTime) {
      createdAt = createdAtValue;
    } else {
      createdAt = DateTime.now();
    }

    // dateの型変換処理
    dynamic dateValue = json['date'];
    DateTime date;
    if (dateValue is Timestamp) {
      date = dateValue.toDate();
    } else if (dateValue is DateTime) {
      date = dateValue;
    } else {
      throw ArgumentError('Invalid date format');
    }

    return TransferRecordModel(
      id: json['id'] as String,
      date: date,
      amount: json['amount'] as int,
      note: json['note'] as String,
      hasCheckedOut: (json['hasCheckedOut'] ?? true) as bool,
      createdAt: createdAt,
      fromProperty: json['fromProperty'] as Map<String, dynamic>,
      toProperty: json['toProperty'] as Map<String, dynamic>,
      type: json['type'] as String? ?? 'transfer',
    );
  }

  /// Firestoreに保存するためのJSONに変換
  /// idは除外（FirestoreのドキュメントIDとして使用されるため）
  Map<String, dynamic> toFirestoreJson() {
    return {
      'date': date,
      'amount': amount,
      'note': note,
      'hasCheckedOut': hasCheckedOut,
      'createdAt': createdAt,
      'fromProperty': fromProperty,
      'toProperty': toProperty,
      'type': type,
    };
  }
}