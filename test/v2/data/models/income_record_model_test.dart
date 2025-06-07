import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/v2/data/models/income_record_model.dart';

void main() {
  group('IncomeRecordModel', () {
    const testId = 'test-income-id';
    final testDate = DateTime(2025, 1, 15);
    const testAmount = 50000;
    const testNote = 'テスト収入';
    const testHasCheckedOut = true;
    final testCreatedAt = DateTime(2025, 1, 15, 10, 30);
    const testProperty = {'ref': 'path/to/property'};
    const testCategory = {'ref': 'path/to/category'};

    test('factoryコンストラクタで正常にインスタンスが作成されること', () {
      final model = IncomeRecordModel(
        id: testId,
        date: testDate,
        amount: testAmount,
        note: testNote,
        hasCheckedOut: testHasCheckedOut,
        createdAt: testCreatedAt,
        property: testProperty,
        category: testCategory,
      );

      expect(model.id, testId);
      expect(model.date, testDate);
      expect(model.amount, testAmount);
      expect(model.note, testNote);
      expect(model.hasCheckedOut, testHasCheckedOut);
      expect(model.createdAt, testCreatedAt);
      expect(model.property, testProperty);
      expect(model.category, testCategory);
      expect(model.type, 'income');
    });

    test('FirestoreJSONからの変換が正常に動作すること（Timestamp使用）', () {
      final json = {
        'id': testId,
        'date': Timestamp.fromDate(testDate),
        'amount': testAmount,
        'note': testNote,
        'hasCheckedOut': testHasCheckedOut,
        'createdAt': Timestamp.fromDate(testCreatedAt),
        'property': testProperty,
        'category': testCategory,
        'type': 'income',
      };

      final model = IncomeRecordModel.fromFirestoreJson(json);

      expect(model.id, testId);
      expect(model.date, testDate);
      expect(model.amount, testAmount);
      expect(model.note, testNote);
      expect(model.hasCheckedOut, testHasCheckedOut);
      expect(model.createdAt, testCreatedAt);
      expect(model.property, testProperty);
      expect(model.category, testCategory);
      expect(model.type, 'income');
    });

    test('標準JSONからの変換が正常に動作すること（DateTime使用）', () {
      final json = {
        'id': testId,
        'date': testDate.toIso8601String(),
        'amount': testAmount,
        'note': testNote,
        'hasCheckedOut': testHasCheckedOut,
        'createdAt': testCreatedAt.toIso8601String(),
        'property': testProperty,
        'category': testCategory,
        'type': 'income',
      };

      final model = IncomeRecordModel.fromFirestoreJson(json);

      expect(model.id, testId);
      expect(model.date, testDate);
      expect(model.amount, testAmount);
      expect(model.note, testNote);
      expect(model.hasCheckedOut, testHasCheckedOut);
      expect(model.createdAt, testCreatedAt);
      expect(model.property, testProperty);
      expect(model.category, testCategory);
      expect(model.type, 'income');
    });

    test('hasCheckedOutが未指定の場合デフォルト値trueが設定されること', () {
      final json = {
        'id': testId,
        'date': testDate,
        'amount': testAmount,
        'note': testNote,
        'createdAt': testCreatedAt,
        'property': testProperty,
        'category': testCategory,
      };

      final model = IncomeRecordModel.fromFirestoreJson(json);

      expect(model.hasCheckedOut, true);
    });

    test('typeが未指定の場合デフォルト値incomeが設定されること', () {
      final json = {
        'id': testId,
        'date': testDate,
        'amount': testAmount,
        'note': testNote,
        'hasCheckedOut': testHasCheckedOut,
        'createdAt': testCreatedAt,
        'property': testProperty,
        'category': testCategory,
      };

      final model = IncomeRecordModel.fromFirestoreJson(json);

      expect(model.type, 'income');
    });

    test('toFirestoreJsonで正常にFirestore用JSONが作成されること', () {
      final model = IncomeRecordModel(
        id: testId,
        date: testDate,
        amount: testAmount,
        note: testNote,
        hasCheckedOut: testHasCheckedOut,
        createdAt: testCreatedAt,
        property: testProperty,
        category: testCategory,
      );

      final json = model.toFirestoreJson();

      expect(json['id'], isNull); // idは含まれない
      expect(json['date'], testDate);
      expect(json['amount'], testAmount);
      expect(json['note'], testNote);
      expect(json['hasCheckedOut'], testHasCheckedOut);
      expect(json['createdAt'], testCreatedAt);
      expect(json['property'], testProperty);
      expect(json['category'], testCategory);
      expect(json['type'], 'income');
    });

    test('不正なdateフォーマットの場合ArgumentErrorがスローされること', () {
      final json = {
        'id': testId,
        'date': 'invalid-date',
        'amount': testAmount,
        'note': testNote,
        'hasCheckedOut': testHasCheckedOut,
        'createdAt': testCreatedAt,
        'property': testProperty,
        'category': testCategory,
      };

      expect(
        () => IncomeRecordModel.fromFirestoreJson(json),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}