import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:household_accounts/data/repositories/record/record_dto.dart';
import 'package:household_accounts/domain/models/amount.dart';
import 'package:household_accounts/domain/models/category_id.dart';
import 'package:household_accounts/domain/models/property_id.dart';
import 'package:household_accounts/domain/models/record.dart';
import 'package:household_accounts/domain/models/record_content.dart';
import 'package:household_accounts/domain/models/record_date.dart';
import 'package:household_accounts/domain/models/record_note.dart';
import 'package:test/test.dart';

void main() {
  group('IncomeRecordDto', () {
    test('正常なドキュメントのとき、ref.id抽出とTimestamp→DateTime変換を含めて変換できること', () {
      final date = DateTime(2026, 8, 20, 10, 30);
      final doc = _fakeDoc('income-1', {
        'type': 'income',
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

    test('ドキュメントIDと中身から直接変換したとき、スナップショット経由と同じ結果になること', () {
      final data = _validIncomeData();

      final fromData = IncomeRecordDto.fromData('income-1', data);
      final fromSnapshot = IncomeRecordDto.fromSnapshot(
        _fakeDoc('income-1', data),
      );

      expect(fromData.id, fromSnapshot.id);
      expect(fromData.date, fromSnapshot.date);
      expect(fromData.amount, fromSnapshot.amount);
      expect(fromData.note, fromSnapshot.note);
      expect(fromData.categoryId, fromSnapshot.categoryId);
      expect(fromData.propertyId, fromSnapshot.propertyId);
    });

    test('typeがincomeでないとき、FormatExceptionが送出されること(コレクション所属だけで種別を決めないこと)', () {
      final doc = _fakeDoc(
        'income-1',
        _validIncomeData()..['type'] = 'expense',
      );

      expect(() => IncomeRecordDto.fromSnapshot(doc), throwsFormatException);
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
        'type': 'expense',
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
        'type': 'expense',
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
          'type': 'transfer',
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
        'type': 'transfer',
        'date': Timestamp.fromDate(DateTime(2026, 8, 22)),
        'amount': 3000,
        'note': '振替',
        'fromProperty': <String, dynamic>{},
        'toProperty': {'ref': _fakeRef('property-4')},
      });

      expect(() => TransferRecordDto.fromSnapshot(doc), throwsFormatException);
    });

    test('typeが欠損しているとき、FormatExceptionが送出されること', () {
      final doc = _fakeDoc('transfer-1', {
        'date': Timestamp.fromDate(DateTime(2026, 8, 22)),
        'amount': 3000,
        'note': '振替',
        'fromProperty': {'ref': _fakeRef('property-3')},
        'toProperty': {'ref': _fakeRef('property-4')},
      });

      expect(() => TransferRecordDto.fromSnapshot(doc), throwsFormatException);
    });
  });

  group('incomeRecordJson', () {
    test('組み立てたJSONのとき、Rulesが受け付ける7フィールドと完全に一致すること', () {
      final json = incomeRecordJson(
        record: _newIncomeRecord(),
        categoryRef: _fakeRef('category-1'),
        propertyRef: _fakeRef('property-1'),
      );

      expect(json.keys.toSet(), {
        'date',
        'amount',
        'note',
        'createdAt',
        'type',
        'category',
        'property',
      });
    });

    test('組み立てたJSONのとき、各フィールドの値が正しいこと', () {
      final date = DateTime(2026, 8, 26, 10);
      final categoryRef = _fakeRef('category-1');
      final propertyRef = _fakeRef('property-1');
      final json = incomeRecordJson(
        record: IncomeRecordContent(
          date: RecordDate(date),
          amount: Amount(1000),
          note: RecordNote('給料'),
          categoryId: CategoryId('category-1'),
          propertyId: PropertyId('property-1'),
        ),
        categoryRef: categoryRef,
        propertyRef: propertyRef,
      );

      expect(json['date'], Timestamp.fromDate(date));
      expect(json['amount'], 1000);
      expect(json['note'], '給料');
      expect(json['createdAt'], isA<FieldValue>());
      expect(json['type'], 'income');
      // _fakeRefは呼び出すたびに新しいインスタンスを返すため、比較には
      // 同一インスタンス(categoryRef/propertyRef)を使う。
      expect(json['category'], {'ref': categoryRef});
      expect(json['property'], {'ref': propertyRef});
    });
  });

  group('expenseRecordJson', () {
    test('組み立てたJSONのとき、Rulesが受け付ける7フィールドと完全に一致すること', () {
      final json = expenseRecordJson(
        record: ExpenseRecordContent(
          date: RecordDate(DateTime(2026, 8, 26)),
          amount: Amount(500),
          note: RecordNote('食費'),
          categoryId: CategoryId('category-2'),
          propertyId: PropertyId('property-2'),
        ),
        categoryRef: _fakeRef('category-2'),
        propertyRef: _fakeRef('property-2'),
      );

      expect(json.keys.toSet(), {
        'date',
        'amount',
        'note',
        'createdAt',
        'type',
        'category',
        'property',
      });
      expect(json['type'], 'expense');
      expect(json['createdAt'], isA<FieldValue>());
    });
  });

  group('transferRecordJson', () {
    test(
      '組み立てたJSONのとき、Rulesが受け付ける7フィールド(fromProperty/toProperty)と完全に一致すること',
      () {
        final fromPropertyRef = _fakeRef('property-3');
        final toPropertyRef = _fakeRef('property-4');
        final json = transferRecordJson(
          record: TransferRecordContent(
            date: RecordDate(DateTime(2026, 8, 26)),
            amount: Amount(3000),
            note: RecordNote('振替'),
            fromPropertyId: PropertyId('property-3'),
            toPropertyId: PropertyId('property-4'),
          ),
          fromPropertyRef: fromPropertyRef,
          toPropertyRef: toPropertyRef,
        );

        expect(json.keys.toSet(), {
          'date',
          'amount',
          'note',
          'createdAt',
          'type',
          'fromProperty',
          'toProperty',
        });
        expect(json['type'], 'transfer');
        expect(json['createdAt'], isA<FieldValue>());
        // _fakeRefは呼び出すたびに新しいインスタンスを返すため、比較には
        // 同一インスタンス(fromPropertyRef/toPropertyRef)を使う。
        expect(json['fromProperty'], {'ref': fromPropertyRef});
        expect(json['toProperty'], {'ref': toPropertyRef});
      },
    );
  });
}

IncomeRecordContent _newIncomeRecord() => IncomeRecordContent(
  date: RecordDate(DateTime(2026, 8, 26)),
  amount: Amount(1000),
  note: RecordNote('給料'),
  categoryId: CategoryId('category-1'),
  propertyId: PropertyId('property-1'),
);

Map<String, dynamic> _validIncomeData() => {
  'type': 'income',
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
