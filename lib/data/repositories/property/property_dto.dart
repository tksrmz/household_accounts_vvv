import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../domain/models/property.dart';
import '../../../domain/models/property_id.dart';

/// propertiesコレクションの1ドキュメントを表すDTO。
class PropertyDto {
  PropertyDto({required this.id, required this.name});

  /// [doc]から[PropertyDto]を組み立てる。
  ///
  /// フィールドの欠損・型不正のときは[FormatException]を送出する。
  factory PropertyDto.fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return PropertyDto(id: doc.id, name: _readName(data, doc.id));
  }

  final String id;
  final String name;

  // amountは読まない(記録入力では資産を選択できれば十分なため。
  // 資産管理画面の移行時に追加する)。
  Property toDomain() => Property(id: PropertyId(id), name: name);
}

String _readName(Map<String, dynamic> data, String docId) {
  final value = data['name'];
  if (value is! String) {
    throw FormatException('name フィールドが不正です: docId=$docId');
  }
  return value;
}
