import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/v2/data/models/expense_category_model.dart';

void main() {
  group('ExpenseCategoryModel', () {
    const testId = 'test-expense-category-id';
    const testName = 'テスト支出カテゴリ';
    const testTotalBudget = 100000;
    const testType = 'expense';

    test('factoryコンストラクタで正常にインスタンスが作成されること', () {
      final model = ExpenseCategoryModel(
        id: testId,
        name: testName,
        totalBudget: testTotalBudget,
      );

      expect(model.id, testId);
      expect(model.name, testName);
      expect(model.totalBudget, testTotalBudget);
      expect(model.type, testType);
    });

    test('JSONからの変換が正常に動作すること', () {
      final json = {
        'id': testId,
        'name': testName,
        'totalBudget': testTotalBudget,
        'type': testType,
      };

      final model = ExpenseCategoryModel.fromJson(json);

      expect(model.id, testId);
      expect(model.name, testName);
      expect(model.totalBudget, testTotalBudget);
      expect(model.type, testType);
    });

    test('typeが未指定の場合デフォルト値expenseが設定されること', () {
      final json = {
        'id': testId,
        'name': testName,
        'totalBudget': testTotalBudget,
      };

      final model = ExpenseCategoryModel.fromJson(json);

      expect(model.type, 'expense');
    });

    test('toFirestoreJsonで正常にFirestore用JSONが作成されること', () {
      final model = ExpenseCategoryModel(
        id: testId,
        name: testName,
        totalBudget: testTotalBudget,
      );

      final json = model.toFirestoreJson();

      expect(json['id'], isNull); // idは含まれない
      expect(json['name'], testName);
      expect(json['totalBudget'], testTotalBudget);
      expect(json['type'], testType);
    });

    test('同じ値を持つインスタンスは等価であること', () {
      final model1 = ExpenseCategoryModel(
        id: testId,
        name: testName,
        totalBudget: testTotalBudget,
      );
      final model2 = ExpenseCategoryModel(
        id: testId,
        name: testName,
        totalBudget: testTotalBudget,
      );

      expect(model1, equals(model2));
      expect(model1.hashCode, equals(model2.hashCode));
    });

    test('異なる値を持つインスタンスは等価でないこと', () {
      final model1 = ExpenseCategoryModel(
        id: testId,
        name: testName,
        totalBudget: testTotalBudget,
      );
      final model2 = ExpenseCategoryModel(
        id: testId,
        name: testName,
        totalBudget: 50000, // 異なる予算
      );

      expect(model1, isNot(equals(model2)));
    });

    test('copyWithメソッドで一部のプロパティを変更できること', () {
      final model = ExpenseCategoryModel(
        id: testId,
        name: testName,
        totalBudget: testTotalBudget,
      );

      final updatedModel = model.copyWith(
        name: '更新されたカテゴリ名',
        totalBudget: 150000,
      );

      expect(updatedModel.id, testId);
      expect(updatedModel.name, '更新されたカテゴリ名');
      expect(updatedModel.totalBudget, 150000);
      expect(updatedModel.type, testType);
    });

    test('totalBudgetが0の場合も正常に処理されること', () {
      final model = ExpenseCategoryModel(
        id: testId,
        name: testName,
        totalBudget: 0,
      );

      expect(model.totalBudget, 0);

      final json = model.toFirestoreJson();
      expect(json['totalBudget'], 0);
    });

    test('totalBudgetが負の値の場合も処理されること', () {
      // ビジネスルールでは負の値は許可されないが、
      // モデル層では技術的制約のみを検証
      final model = ExpenseCategoryModel(
        id: testId,
        name: testName,
        totalBudget: -1000,
      );

      expect(model.totalBudget, -1000);
    });
  });
}