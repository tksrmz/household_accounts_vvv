import 'package:freezed_annotation/freezed_annotation.dart';

part 'property_model.freezed.dart';

@freezed
abstract class PropertyModel with _$PropertyModel {
  const factory PropertyModel({
    required String id,
    required String name,
    required int amount,
  }) = _PropertyModel;

  /// FirestoreからのJSON変換
  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: json['amount'] as int,
    );
  }
}

extension PropertyModelFirestore on PropertyModel {
  /// Firestoreに保存するためのJSONに変換
  /// idは除外（FirestoreのドキュメントIDとして使用されるため）
  Map<String, dynamic> toFirestoreJson() {
    return {
      'name': name,
      'amount': amount,
    };
  }
}