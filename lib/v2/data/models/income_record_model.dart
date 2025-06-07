import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'income_record_model.freezed.dart';

@freezed
abstract class IncomeRecordModel with _$IncomeRecordModel {
  const factory IncomeRecordModel({
    required String id,
    required DateTime date,
    required int amount,
    required String note,
    required bool hasCheckedOut,
    required DateTime createdAt,
    required Map<String, dynamic> property,
    required Map<String, dynamic> category,
    @Default('income') String type,
  }) = _IncomeRecordModel;

  /// Firestoreからの標準的なJSON変換 - Timestampの変換を処理
  factory IncomeRecordModel.fromFirestoreJson(Map<String, dynamic> json) {
    // createdAtの型変換処理
    dynamic createdAtValue = json['createdAt'];
    DateTime createdAt;
    if (createdAtValue is Timestamp) {
      createdAt = createdAtValue.toDate();
    } else if (createdAtValue is DateTime) {
      createdAt = createdAtValue;
    } else if (createdAtValue is String) {
      createdAt = DateTime.parse(createdAtValue);
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
    } else if (dateValue is String) {
      try {
        date = DateTime.parse(dateValue);
      } catch (e) {
        throw ArgumentError('Invalid date format');
      }
    } else {
      throw ArgumentError('Invalid date format');
    }

    return IncomeRecordModel(
      id: json['id'] as String,
      date: date,
      amount: json['amount'] as int,
      note: json['note'] as String,
      hasCheckedOut: (json['hasCheckedOut'] ?? true) as bool,
      createdAt: createdAt,
      property: json['property'] as Map<String, dynamic>,
      category: json['category'] as Map<String, dynamic>,
      type: json['type'] as String? ?? 'income',
    );
  }
}

extension IncomeRecordModelFirestore on IncomeRecordModel {
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