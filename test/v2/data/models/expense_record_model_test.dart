import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/v2/data/models/expense_record_model.dart';

void main() {
  group('ExpenseRecordModel', () {
    const testId = 'test-expense-id';
    final testDate = DateTime(2025, 1, 15);
    const testAmount = 3000;
    const testNote = 'テスト支出';
    const testHasCheckedOut = true;
    final testCreatedAt = DateTime(2025, 1, 15, 10, 30);
    const testProperty = {'ref': 'path/to/property'};
    const testCategory = {'ref': 'path/to/category'};

    test('factoryコンストラクタで正常にインスタンスが作成されること', () {
      final model = ExpenseRecordModel(
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
      expect(model.type, 'expense');
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
        'type': 'expense',
      };

      final model = ExpenseRecordModel.fromJson(json);

      expect(model.id, testId);
      expect(model.date, testDate);
      expect(model.amount, testAmount);
      expect(model.note, testNote);
      expect(model.hasCheckedOut, testHasCheckedOut);
      expect(model.createdAt, testCreatedAt);
      expect(model.property, testProperty);
      expect(model.category, testCategory);
      expect(model.type, 'expense');
    });


    test('hasCheckedOutが未指定の場合デフォルト値trueが設定されること', () {
      final json = {
        'id': testId,
        'date': Timestamp.fromDate(testDate),
        'amount': testAmount,
        'note': testNote,
        'createdAt': Timestamp.fromDate(testCreatedAt),
        'property': testProperty,
        'category': testCategory,
        'type': 'expense',
      };

      final model = ExpenseRecordModel.fromJson(json);

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
        'property': testProperty,
        'category': testCategory,
      };

      expect(
        () => ExpenseRecordModel.fromJson(json),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('toFirestoreJsonで正常にFirestore用JSONが作成されること', () {
      final model = ExpenseRecordModel(
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
      expect(json['type'], 'expense');
    });

  });
}