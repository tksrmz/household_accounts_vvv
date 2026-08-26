import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:household_accounts/data/repositories/category/category_dto.dart';
import 'package:household_accounts/domain/models/category.dart';
import 'package:test/test.dart';

void main() {
  group('IncomeCategoryDto', () {
    test('正常なドキュメントのとき、変換できること', () {
      final doc = _fakeDoc('category-1', {'type': 'income', 'name': '給与'});

      final dto = IncomeCategoryDto.fromSnapshot(doc);

      expect(dto.id, 'category-1');
      expect(dto.name, '給与');
      expect(dto.toDomain(), isA<IncomeCategory>());
    });

    test('typeがincomeでないとき、FormatExceptionが送出されること(コレクション所属だけで種別を決めないこと)', () {
      final doc = _fakeDoc('category-1', {'type': 'expense', 'name': '給与'});

      expect(() => IncomeCategoryDto.fromSnapshot(doc), throwsFormatException);
    });

    test('typeが欠損しているとき、FormatExceptionが送出されること', () {
      final doc = _fakeDoc('category-1', {'name': '給与'});

      expect(() => IncomeCategoryDto.fromSnapshot(doc), throwsFormatException);
    });

    test('nameが欠損しているとき、FormatExceptionが送出されること', () {
      final doc = _fakeDoc('category-1', {'type': 'income'});

      expect(() => IncomeCategoryDto.fromSnapshot(doc), throwsFormatException);
    });

    test('nameが文字列でないとき、FormatExceptionが送出されること', () {
      final doc = _fakeDoc('category-1', {'type': 'income', 'name': 123});

      expect(() => IncomeCategoryDto.fromSnapshot(doc), throwsFormatException);
    });
  });

  group('ExpenseCategoryDto', () {
    test('正常なドキュメントのとき、変換できること', () {
      final doc = _fakeDoc('category-2', {'type': 'expense', 'name': '食費'});

      final dto = ExpenseCategoryDto.fromSnapshot(doc);

      expect(dto.id, 'category-2');
      expect(dto.name, '食費');
      expect(dto.toDomain(), isA<ExpenseCategory>());
    });

    test('typeがexpenseでないとき、FormatExceptionが送出されること', () {
      final doc = _fakeDoc('category-2', {'type': 'income', 'name': '食費'});

      expect(() => ExpenseCategoryDto.fromSnapshot(doc), throwsFormatException);
    });

    test('nameが文字列でないとき、FormatExceptionが送出されること', () {
      final doc = _fakeDoc('category-2', {'type': 'expense', 'name': null});

      expect(() => ExpenseCategoryDto.fromSnapshot(doc), throwsFormatException);
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
