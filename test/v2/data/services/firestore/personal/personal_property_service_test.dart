import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:household_accounts/v2/data/models/property_model.dart';
import 'package:household_accounts/v2/data/services/firestore/personal/personal_property_service.dart';
import 'package:household_accounts/v2/domain/models/vo/user_id.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseFirestore>(),
  MockSpec<CollectionReference<Map<String, dynamic>>>(),
  MockSpec<QuerySnapshot<Map<String, dynamic>>>(),
  MockSpec<QueryDocumentSnapshot<Map<String, dynamic>>>(),
  MockSpec<DocumentReference<Map<String, dynamic>>>(),
])
import 'personal_property_service_test.mocks.dart';

void main() {
  group('PersonalPropertyService', () {
    group('fetchAll', () {
      final mockDb = MockFirebaseFirestore();
      final mockCollectionReference = MockCollectionReference();
      final mockQuerySnapshot = MockQuerySnapshot();
      final mockQueryDocumentSnapshot = MockQueryDocumentSnapshot();
      final userId = UserIdVo('testUserId');

      setUp(() {
        when(mockDb.collection('/personalNotes/${userId.value}/properties'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.get())
            .thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot]);
        when(mockQueryDocumentSnapshot.id).thenReturn('propertyId1');
        when(mockQueryDocumentSnapshot.data()).thenReturn({
          'name': 'Test Property',
          'amount': 10000,
        });
      });

      tearDown(() {
        reset(mockDb);
        reset(mockCollectionReference);
        reset(mockQuerySnapshot);
        reset(mockQueryDocumentSnapshot);
      });

      test('資産のリストを取得できる', () async {
        // Arrange
        final target = PersonalPropertyService(mockDb);

        // Act
        final result = await target.fetchAll(userId);

        // Assert
        verify(mockDb.collection('/personalNotes/${userId.value}/properties'))
            .called(1);
        verify(mockCollectionReference.get()).called(1);
        verify(mockQuerySnapshot.docs).called(1);
        verify(mockQueryDocumentSnapshot.data()).called(1);

        expect(result.isRight(), isTrue);
        final properties = result.getOrElse(List.empty);
        expect(properties, hasLength(1));
        expect(properties[0].id, 'propertyId1');
        expect(properties[0].name, 'Test Property');
        expect(properties[0].amount, 10000);
      });

      test('例外が発生した場合、Leftを返す', () async {
        // Arrange
        when(mockCollectionReference.get()).thenThrow(Exception('test error'));
        final target = PersonalPropertyService(mockDb);

        // Act
        final result = await target.fetchAll(userId);

        // Assert
        expect(result.isLeft(), isTrue);
      });
    });

    group('add', () {
      final mockDb = MockFirebaseFirestore();
      final mockCollectionReference = MockCollectionReference();
      final mockDocumentReference = MockDocumentReference();
      final userId = UserIdVo('testUserId');
      final property = PropertyModel(
        id: 'propertyId1',
        name: 'Test Property',
        amount: 10000,
      );

      setUp(() {
        when(mockDb.collection('/personalNotes/${userId.value}/properties'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(property.id))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.set(any)).thenAnswer((_) async => {});
      });

      tearDown(() {
        reset(mockDb);
        reset(mockCollectionReference);
        reset(mockDocumentReference);
      });

      test('資産を追加できる', () async {
        // Arrange
        final target = PersonalPropertyService(mockDb);

        // Act
        final result = await target.add(userId, property);

        // Assert
        verify(mockDb.collection('/personalNotes/${userId.value}/properties'))
            .called(1);
        verify(mockCollectionReference.doc(property.id)).called(1);
        verify(mockDocumentReference.set(any)).called(1);

        expect(result.isRight(), isTrue);
      });

      test('例外が発生した場合、Leftを返す', () async {
        // Arrange
        when(mockDocumentReference.set(any)).thenThrow(Exception('test error'));
        final target = PersonalPropertyService(mockDb);

        // Act
        final result = await target.add(userId, property);

        // Assert
        expect(result.isLeft(), isTrue);
      });
    });

    group('update', () {
      final mockDb = MockFirebaseFirestore();
      final mockCollectionReference = MockCollectionReference();
      final mockDocumentReference = MockDocumentReference();
      final userId = UserIdVo('testUserId');
      final property = PropertyModel(
        id: 'propertyId1',
        name: 'Updated Property',
        amount: 15000,
      );

      setUp(() {
        when(mockDb.collection('/personalNotes/${userId.value}/properties'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(property.id))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.update(any)).thenAnswer((_) async => {});
      });

      tearDown(() {
        reset(mockDb);
        reset(mockCollectionReference);
        reset(mockDocumentReference);
      });

      test('資産を更新できる', () async {
        // Arrange
        final target = PersonalPropertyService(mockDb);

        // Act
        final result = await target.update(userId, property);

        // Assert
        verify(mockDb.collection('/personalNotes/${userId.value}/properties'))
            .called(1);
        verify(mockCollectionReference.doc(property.id)).called(1);
        verify(mockDocumentReference.update(any)).called(1);

        expect(result.isRight(), isTrue);
      });

      test('例外が発生した場合、Leftを返す', () async {
        // Arrange
        when(mockDocumentReference.update(any))
            .thenThrow(Exception('test error'));
        final target = PersonalPropertyService(mockDb);

        // Act
        final result = await target.update(userId, property);

        // Assert
        expect(result.isLeft(), isTrue);
      });
    });

    group('delete', () {
      final mockDb = MockFirebaseFirestore();
      final mockCollectionReference = MockCollectionReference();
      final mockDocumentReference = MockDocumentReference();
      final userId = UserIdVo('testUserId');
      final propertyId = 'propertyId1';

      setUp(() {
        when(mockDb.collection('/personalNotes/${userId.value}/properties'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(propertyId))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.delete()).thenAnswer((_) async => {});
      });

      tearDown(() {
        reset(mockDb);
        reset(mockCollectionReference);
        reset(mockDocumentReference);
      });

      test('資産を削除できる', () async {
        // Arrange
        final target = PersonalPropertyService(mockDb);

        // Act
        final result = await target.delete(userId, propertyId);

        // Assert
        verify(mockDb.collection('/personalNotes/${userId.value}/properties'))
            .called(1);
        verify(mockCollectionReference.doc(propertyId)).called(1);
        verify(mockDocumentReference.delete()).called(1);

        expect(result.isRight(), isTrue);
      });

      test('例外が発生した場合、Leftを返す', () async {
        // Arrange
        when(mockDocumentReference.delete()).thenThrow(Exception('test error'));
        final target = PersonalPropertyService(mockDb);

        // Act
        final result = await target.delete(userId, propertyId);

        // Assert
        expect(result.isLeft(), isTrue);
      });
    });
  });
}
