import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/v2/data/models/property_model.dart';

void main() {
  group('PropertyModel', () {
    test('正常なデータで資産モデルが作成できること', () {
      const model = PropertyModel(
        id: 'test-property-id',
        name: '現金',
        amount: 10000,
      );

      expect(model.id, 'test-property-id');
      expect(model.name, '現金');
      expect(model.amount, 10000);
    });

    test('負の金額でも資産モデルが作成できること', () {
      const model = PropertyModel(
        id: 'test-property-id',
        name: 'クレジットカード',
        amount: -5000,
      );

      expect(model.id, 'test-property-id');
      expect(model.name, 'クレジットカード');
      expect(model.amount, -5000);
    });

    test('同じ値を持つインスタンスは等価であること', () {
      const model1 = PropertyModel(
        id: 'test-id',
        name: '銀行口座',
        amount: 50000,
      );

      const model2 = PropertyModel(
        id: 'test-id',
        name: '銀行口座',
        amount: 50000,
      );

      expect(model1, model2);
      expect(model1.hashCode, model2.hashCode);
    });

    test('異なる値を持つインスタンスは等価でないこと', () {
      const model1 = PropertyModel(
        id: 'test-id-1',
        name: '現金',
        amount: 10000,
      );

      const model2 = PropertyModel(
        id: 'test-id-2',
        name: '現金',
        amount: 10000,
      );

      expect(model1, isNot(model2));
    });

    group('fromJson', () {
      test('正常なJSONから資産モデルに変換できること', () {
        final json = {
          'id': 'property-123',
          'name': '普通預金',
          'amount': 100000,
        };

        final model = PropertyModel.fromJson(json);

        expect(model.id, 'property-123');
        expect(model.name, '普通預金');
        expect(model.amount, 100000);
      });

      test('金額が0の場合も正常に変換できること', () {
        final json = {
          'id': 'property-456',
          'name': '電子マネー',
          'amount': 0,
        };

        final model = PropertyModel.fromJson(json);

        expect(model.id, 'property-456');
        expect(model.name, '電子マネー');
        expect(model.amount, 0);
      });

      test('金額が負の値の場合も正常に変換できること', () {
        final json = {
          'id': 'property-789',
          'name': 'ローン',
          'amount': -50000,
        };

        final model = PropertyModel.fromJson(json);

        expect(model.id, 'property-789');
        expect(model.name, 'ローン');
        expect(model.amount, -50000);
      });
    });

    group('toFirestoreJson', () {
      test('FirestoreでIDを除外したJSONに変換できること', () {
        const model = PropertyModel(
          id: 'property-id',
          name: '投資信託',
          amount: 250000,
        );

        final json = model.toFirestoreJson();

        expect(json, {
          'name': '投資信託',
          'amount': 250000,
        });

        // IDが含まれていないことを確認
        expect(json.containsKey('id'), false);
      });

      test('金額が0でもFirestore用JSONに変換できること', () {
        const model = PropertyModel(
          id: 'property-id',
          name: '空の財布',
          amount: 0,
        );

        final json = model.toFirestoreJson();

        expect(json, {
          'name': '空の財布',
          'amount': 0,
        });
      });

      test('負の金額でもFirestore用JSONに変換できること', () {
        const model = PropertyModel(
          id: 'property-id',
          name: '借金',
          amount: -30000,
        );

        final json = model.toFirestoreJson();

        expect(json, {
          'name': '借金',
          'amount': -30000,
        });
      });
    });

    group('JSON往復変換', () {
      test('JSONに変換してから再度モデルに戻しても同じ値になること', () {
        const original = PropertyModel(
          id: 'test-id',
          name: 'テスト資産',
          amount: 12345,
        );

        // FirestoreのJSONに変換してIDを追加
        final firestoreJson = original.toFirestoreJson();
        firestoreJson['id'] = original.id;

        // JSONからモデルに戻す
        final restored = PropertyModel.fromJson(firestoreJson);

        expect(restored, original);
      });
    });

    group('エッジケース', () {
      test('空文字の名前でもモデルが作成できること', () {
        const model = PropertyModel(
          id: 'test-id',
          name: '',
          amount: 1000,
        );

        expect(model.name, '');
      });

      test('非常に大きな金額でもモデルが作成できること', () {
        const model = PropertyModel(
          id: 'test-id',
          name: '大金持ち',
          amount: 999999999,
        );

        expect(model.amount, 999999999);
      });

      test('非常に小さな金額でもモデルが作成できること', () {
        const model = PropertyModel(
          id: 'test-id',
          name: '大借金',
          amount: -999999999,
        );

        expect(model.amount, -999999999);
      });
    });
  });
}