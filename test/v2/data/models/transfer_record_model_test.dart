import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/v2/data/models/transfer_record_model.dart';

void main() {
  group('TransferRecordModel', () {
    const testId = 'test-transfer-id';
    final testDate = DateTime(2025, 1, 15);
    const testAmount = 10000;
    const testNote = 'テスト振替';
    const testHasCheckedOut = true;
    final testCreatedAt = DateTime(2025, 1, 15, 10, 30);
    const testFromProperty = {'ref': 'path/to/from-property'};
    const testToProperty = {'ref': 'path/to/to-property'};

    test('factoryコンストラクタで正常にインスタンスが作成されること', () {
      final model = TransferRecordModel(
        id: testId,
        date: testDate,
        amount: testAmount,
        note: testNote,
        hasCheckedOut: testHasCheckedOut,
        createdAt: testCreatedAt,
        fromProperty: testFromProperty,
        toProperty: testToProperty,
      );

      expect(model.id, testId);
      expect(model.date, testDate);
      expect(model.amount, testAmount);
      expect(model.note, testNote);
      expect(model.hasCheckedOut, testHasCheckedOut);
      expect(model.createdAt, testCreatedAt);
      expect(model.fromProperty, testFromProperty);
      expect(model.toProperty, testToProperty);
      expect(model.type, 'transfer');
    });

    test('FirestoreJSONからの変換が正常に動作すること（Timestamp使用）', () {
      final json = {
        'id': testId,
        'date': Timestamp.fromDate(testDate),
        'amount': testAmount,
        'note': testNote,
        'hasCheckedOut': testHasCheckedOut,
        'createdAt': Timestamp.fromDate(testCreatedAt),
        'fromProperty': testFromProperty,
        'toProperty': testToProperty,
        'type': 'transfer',
      };

      final model = TransferRecordModel.fromFirestoreJson(json);

      expect(model.id, testId);
      expect(model.date, testDate);
      expect(model.amount, testAmount);
      expect(model.note, testNote);
      expect(model.hasCheckedOut, testHasCheckedOut);
      expect(model.createdAt, testCreatedAt);
      expect(model.fromProperty, testFromProperty);
      expect(model.toProperty, testToProperty);
      expect(model.type, 'transfer');
    });


    test('hasCheckedOutが未指定の場合デフォルト値trueが設定されること', () {
      final json = {
        'id': testId,
        'date': Timestamp.fromDate(testDate),
        'amount': testAmount,
        'note': testNote,
        'createdAt': Timestamp.fromDate(testCreatedAt),
        'fromProperty': testFromProperty,
        'toProperty': testToProperty,
        'type': 'transfer',
      };

      final model = TransferRecordModel.fromFirestoreJson(json);

      expect(model.hasCheckedOut, true);
    });

    test('typeフィールドが未指定の場合ArgumentErrorがスローされること', () {
      final json = {
        'id': testId,
        'date': testDate,
        'amount': testAmount,
        'note': testNote,
        'hasCheckedOut': testHasCheckedOut,
        'createdAt': testCreatedAt,
        'fromProperty': testFromProperty,
        'toProperty': testToProperty,
      };

      expect(
        () => TransferRecordModel.fromFirestoreJson(json),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('toFirestoreJsonで正常にFirestore用JSONが作成されること', () {
      final model = TransferRecordModel(
        id: testId,
        date: testDate,
        amount: testAmount,
        note: testNote,
        hasCheckedOut: testHasCheckedOut,
        createdAt: testCreatedAt,
        fromProperty: testFromProperty,
        toProperty: testToProperty,
      );

      final json = model.toFirestoreJson();

      expect(json['id'], isNull); // idは含まれない
      expect(json['date'], testDate);
      expect(json['amount'], testAmount);
      expect(json['note'], testNote);
      expect(json['hasCheckedOut'], testHasCheckedOut);
      expect(json['createdAt'], testCreatedAt);
      expect(json['fromProperty'], testFromProperty);
      expect(json['toProperty'], testToProperty);
      expect(json['type'], 'transfer');
    });

  });
}