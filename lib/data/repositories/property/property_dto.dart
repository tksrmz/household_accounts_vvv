import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../domain/models/property.dart';
import '../../../domain/models/property_id.dart';
import '../../../domain/models/property_name.dart';

/// propertiesコレクションの1ドキュメントを表すDTO。
class PropertyDto {
  PropertyDto({required this.id, required this.name, required this.balance});

  /// [doc]から[PropertyDto]を組み立てる。
  ///
  /// フィールドの欠損・型不正のときは[FormatException]を送出する。
  factory PropertyDto.fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return PropertyDto(
      id: doc.id,
      name: _readName(data, doc.id),
      balance: _readBalance(data, doc.id),
    );
  }

  final String id;
  final String name;

  /// 残高。Firestore上のフィールド名は`amount`。
  final int balance;

  /// ドメインモデルへ変換する。名前の値型([PropertyName])の検証違反による
  /// [FormatException]はそのまま透過させる。
  Property toDomain() =>
      Property(id: PropertyId(id), name: PropertyName(name), balance: balance);
}

String _readName(Map<String, dynamic> data, String docId) {
  final value = data['name'];
  if (value is! String) {
    throw FormatException('name フィールドが不正です: docId=$docId');
  }
  return value;
}

/// 残高は支出で負になりうるため、負数も有効な値として受け入れる。
int _readBalance(Map<String, dynamic> data, String docId) {
  final value = data['amount'];
  if (value is! int) {
    throw FormatException('amount フィールドが不正です: docId=$docId');
  }
  return value;
}

/// propertiesコレクションへ新規作成するドキュメントのJSONを組み立てる。
Map<String, Object?> propertyCreateJson({
  required PropertyName name,
  required int balance,
}) => {'name': name.value, 'amount': balance};

/// propertiesドキュメントの部分更新用JSONを組み立てる。
///
/// 渡されたフィールドだけを含める。名前だけの編集で残高を書き戻すと、
/// 編集中に入った残高の増減を古い値で上書きしてしまうため。
Map<String, Object?> propertyUpdateJson({PropertyName? name, int? balance}) => {
  'name': ?name?.value,
  'amount': ?balance,
};
