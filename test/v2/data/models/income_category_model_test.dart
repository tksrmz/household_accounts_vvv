import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/v2/data/models/income_category_model.dart';

void main() {
  group('IncomeCategoryModel', () {
    const testId = 'test-income-category-id';
    const testName = 'テスト収入カテゴリ';
    const testType = 'income';

    test('factoryコンストラクタで正常にインスタンスが作成されること', () {
      final model = IncomeCategoryModel(
        id: testId,
        name: testName,
      );

      expect(model.id, testId);
      expect(model.name, testName);
      expect(model.type, testType);
    });

    test('JSONからの変換が正常に動作すること', () {
      final json = {
        'id': testId,
        'name': testName,
        'type': testType,
      };

      final model = IncomeCategoryModel.fromJson(json);

      expect(model.id, testId);
      expect(model.name, testName);
      expect(model.type, testType);
    });

    test('typeフィールドが未指定の場合ArgumentErrorがスローされること', () {
      final json = {
        'id': testId,
        'name': testName,
      };

      expect(
        () => IncomeCategoryModel.fromJson(json),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('toFirestoreJsonで正常にFirestore用JSONが作成されること', () {
      final model = IncomeCategoryModel(
        id: testId,
        name: testName,
      );

      final json = model.toFirestoreJson();

      expect(json['id'], isNull); // idは含まれない
      expect(json['name'], testName);
      expect(json['type'], testType);
    });

    test('同じ値を持つインスタンスは等価であること', () {
      final model1 = IncomeCategoryModel(
        id: testId,
        name: testName,
      );
      final model2 = IncomeCategoryModel(
        id: testId,
        name: testName,
      );

      expect(model1, equals(model2));
      expect(model1.hashCode, equals(model2.hashCode));
    });

    test('異なる値を持つインスタンスは等価でないこと', () {
      final model1 = IncomeCategoryModel(
        id: testId,
        name: testName,
      );
      final model2 = IncomeCategoryModel(
        id: 'different-id',
        name: testName,
      );

      expect(model1, isNot(equals(model2)));
    });

    test('copyWithメソッドで一部のプロパティを変更できること', () {
      final model = IncomeCategoryModel(
        id: testId,
        name: testName,
      );

      final updatedModel = model.copyWith(name: '更新されたカテゴリ名');

      expect(updatedModel.id, testId);
      expect(updatedModel.name, '更新されたカテゴリ名');
      expect(updatedModel.type, testType);
    });
  });
}
