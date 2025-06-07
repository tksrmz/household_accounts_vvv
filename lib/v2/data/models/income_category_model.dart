import 'package:freezed_annotation/freezed_annotation.dart';

part 'income_category_model.freezed.dart';

@freezed
class IncomeCategoryModel with _$IncomeCategoryModel {
  const IncomeCategoryModel._();

  const factory IncomeCategoryModel({
    required String id,
    required String name,
    @Default('income') String type,
  }) = _IncomeCategoryModel;

  /// FirestoreからのJSON変換
  factory IncomeCategoryModel.fromJson(Map<String, dynamic> json) {
    return IncomeCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String? ?? 'income',
    );
  }

  /// Firestoreに保存するためのJSONに変換
  /// idは除外（FirestoreのドキュメントIDとして使用されるため）
  Map<String, dynamic> toFirestoreJson() {
    return {
      'name': name,
      'type': type,
    };
  }
}