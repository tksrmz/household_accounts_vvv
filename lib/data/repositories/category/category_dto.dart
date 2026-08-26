import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../domain/models/category.dart';
import '../../../domain/models/category_id.dart';

// incomeCategories/expenseCategoriesのFirestoreドキュメントは形が似ているが、
// 収入カテゴリと支出カテゴリはドメイン的に別物である(支出カテゴリだけが
// 今後予算を持つ)ため、DTOクラスを共用しない。

/// incomeCategoriesコレクションの1ドキュメントを表すDTO。
class IncomeCategoryDto {
  IncomeCategoryDto({required this.id, required this.name});

  /// [doc]から[IncomeCategoryDto]を組み立てる。
  ///
  /// フィールドの欠損・型不正、および`type`フィールドが`income`でないときは
  /// [FormatException]を送出する。
  factory IncomeCategoryDto.fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    _requireType(data, 'income', doc.id);
    return IncomeCategoryDto(id: doc.id, name: _readName(data, doc.id));
  }

  final String id;
  final String name;

  /// ドメインモデルへ変換する。名前の文字数検証はまだない(カテゴリ管理画面の
  /// 移行時に検証付き値型化する)ため、ここでの変換自体は失敗しない。
  IncomeCategory toDomain() => IncomeCategory(id: CategoryId(id), name: name);
}

/// expenseCategoriesコレクションの1ドキュメントを表すDTO。
class ExpenseCategoryDto {
  ExpenseCategoryDto({required this.id, required this.name});

  /// [doc]から[ExpenseCategoryDto]を組み立てる。
  ///
  /// フィールドの欠損・型不正、および`type`フィールドが`expense`でないときは
  /// [FormatException]を送出する。
  factory ExpenseCategoryDto.fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    _requireType(data, 'expense', doc.id);
    return ExpenseCategoryDto(id: doc.id, name: _readName(data, doc.id));
  }

  final String id;
  final String name;

  // totalBudgetは読まない(記録入力ではカテゴリを選択できれば十分なため。
  // カテゴリ管理画面の移行時に追加する)。
  ExpenseCategory toDomain() => ExpenseCategory(id: CategoryId(id), name: name);
}

/// カテゴリ種別(`type`フィールド)が[expected]と一致することを検証する。
///
/// コレクションの所属だけで種別を決めると、誤った場所に置かれた
/// ドキュメントを黙って別種別として扱ってしまうため、
/// ドキュメント自身が宣言する種別と突き合わせる。
void _requireType(Map<String, dynamic> data, String expected, String docId) {
  final value = data['type'];
  if (value != expected) {
    throw FormatException('type フィールドが不正です(期待: $expected): docId=$docId');
  }
}

String _readName(Map<String, dynamic> data, String docId) {
  final value = data['name'];
  if (value is! String) {
    throw FormatException('name フィールドが不正です: docId=$docId');
  }
  return value;
}
