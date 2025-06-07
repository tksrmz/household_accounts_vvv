import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense_category_model.freezed.dart';

@freezed
abstract class ExpenseCategoryModel with _$ExpenseCategoryModel {
  const factory ExpenseCategoryModel({
    required String id,
    required String name,
    required int totalBudget,
    @Default('expense') String type,
  }) = _ExpenseCategoryModel;

  /// FirestoreからのJSON変換
  factory ExpenseCategoryModel.fromJson(Map<String, dynamic> json) {
    return ExpenseCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      totalBudget: json['totalBudget'] as int,
      type: json['type'] as String? ?? 'expense',
    );
  }
}

extension ExpenseCategoryModelFirestore on ExpenseCategoryModel {
  /// Firestoreに保存するためのJSONに変換
  /// idは除外（FirestoreのドキュメントIDとして使用されるため）
  Map<String, dynamic> toFirestoreJson() {
    return {
      'name': name,
      'totalBudget': totalBudget,
      'type': type,
    };
  }
}