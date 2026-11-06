import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:household_accounts/data/repositories/property/property_dto.dart';
import 'package:household_accounts/domain/models/property.dart';
import 'package:household_accounts/domain/models/property_name.dart';
import 'package:test/test.dart';

void main() {
  group('PropertyDto', () {
    test('正常なドキュメントのとき、変換できること', () {
      final doc = _fakeDoc('property-1', {'name': '財布', 'amount': 1200});

      final dto = PropertyDto.fromSnapshot(doc);

      expect(dto.id, 'property-1');
      expect(dto.name, '財布');
      expect(dto.balance, 1200);
      expect(dto.toDomain(), isA<Property>());
    });

    test('nameが欠損しているとき、FormatExceptionが送出されること', () {
      final doc = _fakeDoc('property-1', {'amount': 0});

      expect(() => PropertyDto.fromSnapshot(doc), throwsFormatException);
    });

    test('nameが文字列でないとき、FormatExceptionが送出されること', () {
      final doc = _fakeDoc('property-1', {'name': 123, 'amount': 0});

      expect(() => PropertyDto.fromSnapshot(doc), throwsFormatException);
    });

    test('nameが21文字のとき、toDomainでFormatExceptionが送出されること', () {
      final doc = _fakeDoc('property-1', {'name': 'a' * 21, 'amount': 0});

      final dto = PropertyDto.fromSnapshot(doc);

      expect(() => dto.toDomain(), throwsFormatException);
    });

    test('amountが欠損しているとき、FormatExceptionが送出されること', () {
      final doc = _fakeDoc('property-1', {'name': '財布'});

      expect(() => PropertyDto.fromSnapshot(doc), throwsFormatException);
    });

    test('amountが整数でないとき、FormatExceptionが送出されること', () {
      final doc = _fakeDoc('property-1', {'name': '財布', 'amount': 1.5});

      expect(() => PropertyDto.fromSnapshot(doc), throwsFormatException);
    });

    test('amountが負数のとき、そのまま残高として変換できること', () {
      final doc = _fakeDoc('property-1', {'name': '財布', 'amount': -300});

      expect(PropertyDto.fromSnapshot(doc).toDomain().balance, -300);
    });
  });

  group('propertyCreateJson', () {
    test('名前と残高を渡したとき、nameとamountの2フィールドになること', () {
      expect(propertyCreateJson(name: PropertyName('財布'), balance: -10), {
        'name': '財布',
        'amount': -10,
      });
    });
  });

  group('propertyUpdateJson', () {
    test('名前だけを渡したとき、nameのみを含むこと', () {
      expect(propertyUpdateJson(name: PropertyName('銀行')), {'name': '銀行'});
    });

    test('残高だけを渡したとき、amountのみを含むこと', () {
      expect(propertyUpdateJson(balance: 0), {'amount': 0});
    });

    test('名前と残高の両方を渡したとき、nameとamountの両方を含むこと', () {
      expect(propertyUpdateJson(name: PropertyName('銀行'), balance: -500), {
        'name': '銀行',
        'amount': -500,
      });
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
