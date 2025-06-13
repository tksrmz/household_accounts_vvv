import 'package:dartz/dartz.dart';
import 'package:household_accounts/v2/data/repositories/firestore/property_repository.dart';
import 'package:household_accounts/v2/data/services/firestore_service.dart';
import 'package:household_accounts/v2/data/models/property_model.dart' as data;
import 'package:household_accounts/v2/domain/models/property.dart';
import 'package:household_accounts/v2/domain/models/vo/property_amount.dart';
import 'package:household_accounts/v2/domain/models/vo/property_id.dart';
import 'package:household_accounts/v2/domain/models/vo/property_name.dart';
import 'package:household_accounts/v2/domain/models/vo/user_id.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

@GenerateNiceMocks([
  MockSpec<FirestoreService>(),
])
import 'property_repository_test.mocks.dart';

void main() {
  group('fetchAll', () {
    final MockFirestoreService mockFirestoreService = MockFirestoreService();
    const UserIdVo userId = UserIdVo('samplePersonalNoteId');

    tearDown(() {
      reset(mockFirestoreService);
    });

    test('資産一覧を取得できる', () async {
      final mockModel = data.PropertyModel(
        id: 'test-property-id',
        name: 'テスト資産',
        amount: 100000,
      );

      when(mockFirestoreService.fetchPersonalProperties(
        userId,
      )).thenAnswer((_) async => Right([mockModel]));

      final target = FirestorePropertyRepository(
        mockFirestoreService,
        userId,
      );
      final result = await target.fetchAll();
      final propertyList = result.getOrElse(() => []);

      verify(mockFirestoreService.fetchPersonalProperties(
        userId,
      )).called(1);

      expect(result.isRight(), isTrue);
      expect(propertyList, hasLength(1));
      expect(propertyList[0].id.value, equals('test-property-id'));
      expect(propertyList[0].name.value, equals('テスト資産'));
      expect(propertyList[0].amount.value, equals(100000));
    });

    test('資産が存在しない場合、空のリストを返す', () async {
      when(mockFirestoreService.fetchPersonalProperties(
        userId,
      )).thenAnswer((_) async => Right([]));

      final target = FirestorePropertyRepository(
        mockFirestoreService,
        userId,
      );
      final result = await target.fetchAll();
      final propertyList = result.getOrElse(() => []);

      expect(result.isRight(), isTrue);
      expect(propertyList, hasLength(0));
    });

    test('FirestoreServiceから例外が返された場合、Leftを返す', () async {
      final exception = Exception('test error');
      when(mockFirestoreService.fetchPersonalProperties(
        userId,
      )).thenAnswer((_) async => Left(exception));

      final target = FirestorePropertyRepository(
        mockFirestoreService,
        userId,
      );
      final result = await target.fetchAll();

      expect(result.isLeft(), isTrue);
      expect(result.fold((l) => l, (r) => null), equals(exception));
    });
  });

  group('add', () {
    final MockFirestoreService mockFirestoreService = MockFirestoreService();
    const UserIdVo userId = UserIdVo('samplePersonalNoteId');

    tearDown(() {
      reset(mockFirestoreService);
    });

    test('資産を追加できる', () async {
      final property = PropertyModel(
        id: PropertyIdVo('test-property-id'),
        name: PropertyNameVo('テスト資産'),
        amount: PropertyAmountVo(100000),
      );

      when(mockFirestoreService.addPersonalProperty(
        userId,
        any,
      )).thenAnswer((_) async => Right(unit));

      final target = FirestorePropertyRepository(
        mockFirestoreService,
        userId,
      );
      final result = await target.add(property);

      verify(mockFirestoreService.addPersonalProperty(
        userId,
        any,
      )).called(1);

      expect(result.isRight(), isTrue);
    });

    test('FirestoreServiceから例外が返された場合、Leftを返す', () async {
      final property = PropertyModel(
        id: PropertyIdVo('test-property-id'),
        name: PropertyNameVo('テスト資産'),
        amount: PropertyAmountVo(100000),
      );

      final exception = Exception('test error');
      when(mockFirestoreService.addPersonalProperty(
        userId,
        any,
      )).thenAnswer((_) async => Left(exception));

      final target = FirestorePropertyRepository(
        mockFirestoreService,
        userId,
      );
      final result = await target.add(property);

      expect(result.isLeft(), isTrue);
      expect(result.fold((l) => l, (r) => null), equals(exception));
    });
  });

  group('update', () {
    final MockFirestoreService mockFirestoreService = MockFirestoreService();
    const UserIdVo userId = UserIdVo('samplePersonalNoteId');

    tearDown(() {
      reset(mockFirestoreService);
    });

    test('資産を更新できる', () async {
      const propertyId = PropertyIdVo('test-property-id');
      final property = PropertyModel(
        id: propertyId,
        name: PropertyNameVo('更新された資産'),
        amount: PropertyAmountVo(150000),
      );

      when(mockFirestoreService.updatePersonalProperty(
        userId,
        any,
      )).thenAnswer((_) async => Right(unit));

      final target = FirestorePropertyRepository(
        mockFirestoreService,
        userId,
      );
      final result = await target.update(propertyId, property);

      verify(mockFirestoreService.updatePersonalProperty(
        userId,
        any,
      )).called(1);

      expect(result.isRight(), isTrue);
    });

    test('FirestoreServiceから例外が返された場合、Leftを返す', () async {
      const propertyId = PropertyIdVo('test-property-id');
      final property = PropertyModel(
        id: propertyId,
        name: PropertyNameVo('更新された資産'),
        amount: PropertyAmountVo(150000),
      );

      final exception = Exception('test error');
      when(mockFirestoreService.updatePersonalProperty(
        userId,
        any,
      )).thenAnswer((_) async => Left(exception));

      final target = FirestorePropertyRepository(
        mockFirestoreService,
        userId,
      );
      final result = await target.update(propertyId, property);

      expect(result.isLeft(), isTrue);
      expect(result.fold((l) => l, (r) => null), equals(exception));
    });
  });

  group('delete', () {
    final MockFirestoreService mockFirestoreService = MockFirestoreService();
    const UserIdVo userId = UserIdVo('samplePersonalNoteId');

    tearDown(() {
      reset(mockFirestoreService);
    });

    test('資産を削除できる', () async {
      const propertyId = PropertyIdVo('test-property-id');

      when(mockFirestoreService.deletePersonalProperty(
        userId,
        propertyId.value,
      )).thenAnswer((_) async => Right(unit));

      final target = FirestorePropertyRepository(
        mockFirestoreService,
        userId,
      );
      final result = await target.delete(propertyId);

      verify(mockFirestoreService.deletePersonalProperty(
        userId,
        propertyId.value,
      )).called(1);

      expect(result.isRight(), isTrue);
    });

    test('FirestoreServiceから例外が返された場合、Leftを返す', () async {
      const propertyId = PropertyIdVo('test-property-id');
      final exception = Exception('test error');

      when(mockFirestoreService.deletePersonalProperty(
        userId,
        propertyId.value,
      )).thenAnswer((_) async => Left(exception));

      final target = FirestorePropertyRepository(
        mockFirestoreService,
        userId,
      );
      final result = await target.delete(propertyId);

      expect(result.isLeft(), isTrue);
      expect(result.fold((l) => l, (r) => null), equals(exception));
    });
  });
}