import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transfer_record_model.freezed.dart';

@freezed
abstract class TransferRecordModel with _$TransferRecordModel {
  /// TransferRecordModelのコンストラクタ
  ///
  /// テストコードでのみ使用すること。
  /// プロダクションコードでは TransferRecordModel.fromJson() を使用する。
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
  factory TransferRecordModel.fromJson(Map<String, dynamic> json) {
    // typeの検証
    if (!json.containsKey('type')) {
      throw ArgumentError('TransferRecordModel requires "type" field in JSON');
    }
    final type = json['type'] as String;
    if (type != 'transfer') {
      throw ArgumentError(
          'TransferRecordModel requires type "transfer", but got "$type"');
    }
    // createdAtの型変換処理
    Timestamp createdAtTimestamp = json['createdAt'] as Timestamp;
    DateTime createdAt = createdAtTimestamp.toDate();

    // dateの型変換処理
    Timestamp dateTimestamp = json['date'] as Timestamp;
    DateTime date = dateTimestamp.toDate();

    return TransferRecordModel(
      id: json['id'] as String,
      date: date,
      amount: json['amount'] as int,
      note: json['note'] as String,
      hasCheckedOut: (json['hasCheckedOut'] ?? true) as bool,
      createdAt: createdAt,
      fromProperty: json['fromProperty'] as Map<String, dynamic>,
      toProperty: json['toProperty'] as Map<String, dynamic>,
      type: type,
    );
  }
}

extension TransferRecordModelFirestore on TransferRecordModel {
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
