import 'package:freezed_annotation/freezed_annotation.dart';

part 'income_category_model.freezed.dart';

@freezed
abstract class IncomeCategoryModel with _$IncomeCategoryModel {
  /// IncomeCategoryModelのコンストラクタ
  /// 
  /// テストコードでのみ使用すること。
  /// プロダクションコードでは IncomeCategoryModel.fromJson() を使用する。
  const factory IncomeCategoryModel({
    required String id,
    required String name,
    @Default('income') String type,
  }) = _IncomeCategoryModel;

  /// FirestoreからのJSON変換
  factory IncomeCategoryModel.fromJson(Map<String, dynamic> json) {
    // typeの検証
    if (!json.containsKey('type')) {
      throw ArgumentError('IncomeCategoryModel requires "type" field in JSON');
    }
    final type = json['type'] as String;
    if (type != 'income') {
      throw ArgumentError('IncomeCategoryModel requires type "income", but got "$type"');
    }
    return IncomeCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: type,
    );
  }
}

extension IncomeCategoryModelFirestore on IncomeCategoryModel {
  /// Firestoreに保存するためのJSONに変換
  /// idは除外（FirestoreのドキュメントIDとして使用されるため）
  Map<String, dynamic> toFirestoreJson() {
    return {
      'name': name,
      'type': type,
    };
  }
}