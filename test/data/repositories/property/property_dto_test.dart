import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:household_accounts/data/repositories/property/property_dto.dart';
import 'package:household_accounts/domain/models/property.dart';
import 'package:test/test.dart';

void main() {
  group('PropertyDto', () {
    test('正常なドキュメントのとき、変換できること', () {
      final doc = _fakeDoc('property-1', {'name': '財布'});

      final dto = PropertyDto.fromSnapshot(doc);

      expect(dto.id, 'property-1');
      expect(dto.name, '財布');
      expect(dto.toDomain(), isA<Property>());
    });

    test('nameが欠損しているとき、FormatExceptionが送出されること', () {
      final doc = _fakeDoc('property-1', {});

      expect(() => PropertyDto.fromSnapshot(doc), throwsFormatException);
    });

    test('nameが文字列でないとき、FormatExceptionが送出されること', () {
      final doc = _fakeDoc('property-1', {'name': 123});

      expect(() => PropertyDto.fromSnapshot(doc), throwsFormatException);
    });
  });
}

QueryDocumentSnapshot<Map<String, dynamic>> _fakeDoc(
  String id,
  Map<String, dynamic> data,
) => _FakeQueryDocumentSnapshot(id, data);

// ignore: subtype_of_sealed_class
/// mocktail/mockitoを使わない手書きFake。実際に使うメンバ([id]/[data])のみ
/// overrideし、それ以外はテストで呼ばれないためnoSuchMethodへ委譲する。
///
/// [QueryDocumentSnapshot]([DocumentSnapshot]も含め)はcloud_firestore
/// パッケージが`@sealed`を付けている(外部実装を非推奨とするための注釈であり、
/// 言語レベルのsealedではない)ため`subtype_of_sealed_class`が警告として
/// 出るが、テスト用のFakeとして意図的にimplementsしている。
class _FakeQueryDocumentSnapshot
    implements QueryDocumentSnapshot<Map<String, dynamic>> {
  _FakeQueryDocumentSnapshot(this.id, this._data);

  @override
  final String id;

  final Map<String, dynamic> _data;

  @override
  Map<String, dynamic> data() => _data;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
