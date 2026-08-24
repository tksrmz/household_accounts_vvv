import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:household_accounts/data/repositories/record/record_dto.dart';
import 'package:household_accounts/domain/models/record.dart';
import 'package:test/test.dart';

void main() {
  group('IncomeRecordDto', () {
    test('正常なドキュメントのとき、ref.id抽出とTimestamp→DateTime変換を含めて変換できること', () {
      final date = DateTime(2026, 8, 20, 10, 30);
      final doc = _fakeDoc('income-1', {
        'date': Timestamp.fromDate(date),
        'amount': 1000,
        'note': '給料',
        'category': {'ref': _fakeRef('category-1')},
        'property': {'ref': _fakeRef('property-1')},
      });

      final dto = IncomeRecordDto.fromSnapshot(doc);

      expect(dto.id, 'income-1');
      expect(dto.date, date);
      expect(dto.amount, 1000);
      expect(dto.note, '給料');
      expect(dto.categoryId, 'category-1');
      expect(dto.propertyId, 'property-1');
      expect(dto.toDomain(), isA<IncomeRecord>());
    });

    test('dateがTimestampでないとき、FormatExceptionが送出されること', () {
      final doc = _fakeDoc(
        'income-1',
        _validIncomeData()..['date'] = '2026-08-20',
      );

      expect(() => IncomeRecordDto.fromSnapshot(doc), throwsFormatException);
    });

    test('amountがintでないとき、FormatExceptionが送出されること', () {
      final doc = _fakeDoc('income-1', _validIncomeData()..['amount'] = '1000');

      expect(() => IncomeRecordDto.fromSnapshot(doc), throwsFormatException);
    });

    test('noteが欠損しているとき、FormatExceptionが送出されること', () {
      final doc = _fakeDoc('income-1', _validIncomeData()..remove('note'));

      expect(() => IncomeRecordDto.fromSnapshot(doc), throwsFormatException);
    });

    test('categoryのrefが欠損しているとき、FormatExceptionが送出されること', () {
      final doc = _fakeDoc(
        'income-1',
        _validIncomeData()..['category'] = <String, dynamic>{},
      );

      expect(() => IncomeRecordDto.fromSnapshot(doc), throwsFormatException);
    });

    test('amountが0のとき、toDomainでFormatExceptionが送出されること(値型の検証が透過すること)', () {
      final doc = _fakeDoc('income-1', _validIncomeData()..['amount'] = 0);

      expect(
        () => IncomeRecordDto.fromSnapshot(doc).toDomain(),
        throwsFormatException,
      );
    });

    test('noteが101文字のとき、toDomainでFormatExceptionが送出されること(値型の検証が透過すること)', () {
      final doc = _fakeDoc(
        'income-1',
        _validIncomeData()..['note'] = 'a' * 101,
      );

      expect(
        () => IncomeRecordDto.fromSnapshot(doc).toDomain(),
        throwsFormatException,
      );
    });
  });

  group('ExpenseRecordDto', () {
    test('正常なドキュメントのとき、ref.id抽出とTimestamp→DateTime変換を含めて変換できること', () {
      final date = DateTime(2026, 8, 21, 9);
      final doc = _fakeDoc('expense-1', {
        'date': Timestamp.fromDate(date),
        'amount': 500,
        'note': '食費',
        'category': {'ref': _fakeRef('category-2')},
        'property': {'ref': _fakeRef('property-2')},
      });

      final dto = ExpenseRecordDto.fromSnapshot(doc);

      expect(dto.id, 'expense-1');
      expect(dto.date, date);
      expect(dto.amount, 500);
      expect(dto.note, '食費');
      expect(dto.categoryId, 'category-2');
      expect(dto.propertyId, 'property-2');
      expect(dto.toDomain(), isA<ExpenseRecord>());
    });

    test('propertyのrefが欠損しているとき、FormatExceptionが送出されること', () {
      final doc = _fakeDoc('expense-1', {
        'date': Timestamp.fromDate(DateTime(2026, 8, 21)),
        'amount': 500,
        'note': '食費',
        'category': {'ref': _fakeRef('category-2')},
        'property': <String, dynamic>{},
      });

      expect(() => ExpenseRecordDto.fromSnapshot(doc), throwsFormatException);
    });
  });

  group('TransferRecordDto', () {
    test(
      '正常なドキュメントのとき、fromProperty/toPropertyのref.id抽出とTimestamp→DateTime変換を含めて変換できること',
      () {
        final date = DateTime(2026, 8, 22, 12);
        final doc = _fakeDoc('transfer-1', {
          'date': Timestamp.fromDate(date),
          'amount': 3000,
          'note': '振替',
          'fromProperty': {'ref': _fakeRef('property-3')},
          'toProperty': {'ref': _fakeRef('property-4')},
        });

        final dto = TransferRecordDto.fromSnapshot(doc);

        expect(dto.id, 'transfer-1');
        expect(dto.date, date);
        expect(dto.amount, 3000);
        expect(dto.note, '振替');
        expect(dto.fromPropertyId, 'property-3');
        expect(dto.toPropertyId, 'property-4');
        expect(dto.toDomain(), isA<TransferRecord>());
      },
    );

    test('fromPropertyのrefが欠損しているとき、FormatExceptionが送出されること', () {
      final doc = _fakeDoc('transfer-1', {
        'date': Timestamp.fromDate(DateTime(2026, 8, 22)),
        'amount': 3000,
        'note': '振替',
        'fromProperty': <String, dynamic>{},
        'toProperty': {'ref': _fakeRef('property-4')},
      });

      expect(() => TransferRecordDto.fromSnapshot(doc), throwsFormatException);
    });
  });
}

Map<String, dynamic> _validIncomeData() => {
  'date': Timestamp.fromDate(DateTime(2026, 8, 20)),
  'amount': 1000,
  'note': '給料',
  'category': {'ref': _fakeRef('category-1')},
  'property': {'ref': _fakeRef('property-1')},
};

QueryDocumentSnapshot<Map<String, dynamic>> _fakeDoc(
  String id,
  Map<String, dynamic> data,
) => _FakeQueryDocumentSnapshot(id, data);

DocumentReference<Map<String, dynamic>> _fakeRef(String id) =>
    _FakeDocumentReference(id);

// ignore: subtype_of_sealed_class
/// mocktail/mockitoを使わない手書きFake。実際に使うメンバ([id])のみoverrideし、
/// それ以外はテストで呼ばれないためnoSuchMethodへ委譲する。
///
/// [DocumentReference]はcloud_firestoreパッケージが`@sealed`を付けている
/// (外部実装を非推奨とするための注釈であり、言語レベルのsealedではない)ため
/// `subtype_of_sealed_class`が警告として出るが、テスト用のFakeとして
/// 意図的にimplementsしている。
class _FakeDocumentReference
    implements DocumentReference<Map<String, dynamic>> {
  _FakeDocumentReference(this.id);

  @override
  final String id;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

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
