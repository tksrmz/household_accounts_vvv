import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:household_accounts/v2/data/services/firestore_service.dart';
import 'package:household_accounts/v2/domain/models/vo/user_id.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseFirestore>(),
  MockSpec<CollectionReference<Map<String, dynamic>>>(),
  MockSpec<Query<Map<String, dynamic>>>(),
  MockSpec<QuerySnapshot<Map<String, dynamic>>>(),
  MockSpec<QueryDocumentSnapshot<Map<String, dynamic>>>(),
])
import 'firestore_service_test.mocks.dart';

void main() {
  group('FirestoreService', () {
    group('fetchAllPersonalExpensesOf', () {
      final mockDb = MockFirebaseFirestore();
      final mockCollectionReference = MockCollectionReference();
      final mockQuery = MockQuery();
      final mockQuerySnapshot = MockQuerySnapshot();
      final mockQueryDocumentSnapshot = MockQueryDocumentSnapshot();
      final userId = UserIdVo('testUserId');

      setUp(() {
        when(mockDb.collection('/personalNotes/${userId.value}/expenses'))
            .thenReturn(mockCollectionReference);
        when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot]);
        when(mockQueryDocumentSnapshot.data()).thenReturn({
          'amount': 1000,
          'date': DateTime(2025, 5, 25),
        });
        when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      });

      tearDown(() {
        reset(mockDb);
        reset(mockCollectionReference);
        reset(mockQuery);
        reset(mockQuerySnapshot);
        reset(mockQueryDocumentSnapshot);
      });

      test('年のみ指定した場合、その年のすべての支出を取得する', () async {
        // Arrange
        when(mockCollectionReference.where(
          'date',
          isGreaterThanOrEqualTo: DateTime(2025, 1, 1),
          isLessThan: DateTime(2026, 1, 1),
        )).thenReturn(mockQuery);

        final sut = FirestoreService(mockDb);

        // Act
        final result = await sut.fetchAllPersonalExpensesOf(userId, 2025);

        // Assert
        verify(mockDb.collection('/personalNotes/${userId.value}/expenses')).called(1);
        verify(mockCollectionReference.where(
          'date',
          isGreaterThanOrEqualTo: DateTime(2025, 1, 1),
          isLessThan: DateTime(2026, 1, 1),
        )).called(1);
        verify(mockQuery.get()).called(1);
        verify(mockQuerySnapshot.docs).called(1);
        verify(mockQueryDocumentSnapshot.data()).called(1);

        expect(result, isA<List<Map<String, dynamic>>>());
        expect(result.length, 1);
        expect(result[0]['amount'], 1000);
      });

      test('年と月を指定した場合、その月のすべての支出を取得する', () async {
        // Arrange
        when(mockCollectionReference.where(
          'date',
          isGreaterThanOrEqualTo: DateTime(2025, 5, 1),
          isLessThan: DateTime(2025, 6, 1),
        )).thenReturn(mockQuery);

        final sut = FirestoreService(mockDb);

        // Act
        final result = await sut.fetchAllPersonalExpensesOf(userId, 2025, 5);

        // Assert
        verify(mockDb.collection('/personalNotes/${userId.value}/expenses')).called(1);
        verify(mockCollectionReference.where(
          'date',
          isGreaterThanOrEqualTo: DateTime(2025, 5, 1),
          isLessThan: DateTime(2025, 6, 1),
        )).called(1);
        verify(mockQuery.get()).called(1);
        expect(result.length, 1);
        expect(result[0]['amount'], 1000);
      });

      test('年と月と日を指定した場合、その日のすべての支出を取得する', () async {
        // Arrange
        when(mockCollectionReference.where(
          'date',
          isGreaterThanOrEqualTo: DateTime(2025, 5, 25),
          isLessThan: DateTime(2025, 5, 26),
        )).thenReturn(mockQuery);

        final sut = FirestoreService(mockDb);

        // Act
        final result = await sut.fetchAllPersonalExpensesOf(userId, 2025, 5, 25);

        // Assert
        verify(mockDb.collection('/personalNotes/${userId.value}/expenses')).called(1);
        verify(mockCollectionReference.where(
          'date',
          isGreaterThanOrEqualTo: DateTime(2025, 5, 25),
          isLessThan: DateTime(2025, 5, 26),
        )).called(1);
        verify(mockQuery.get()).called(1);
        expect(result.length, 1);
        expect(result[0]['amount'], 1000);
      });

      test('複数のドキュメントが返された場合、すべてのドキュメントを返す', () async {
        // Arrange
        when(mockCollectionReference.where(
          'date',
          isGreaterThanOrEqualTo: DateTime(2025, 5, 1),
          isLessThan: DateTime(2025, 6, 1),
        )).thenReturn(mockQuery);
        when(mockQuerySnapshot.docs).thenReturn([
          mockQueryDocumentSnapshot,
          mockQueryDocumentSnapshot,
        ]);
        when(mockQueryDocumentSnapshot.data()).thenReturnInOrder([
          {'amount': 1000, 'date': DateTime(2025, 5, 10)},
          {'amount': 2000, 'date': DateTime(2025, 5, 20)},
        ]);

        final sut = FirestoreService(mockDb);

        // Act
        final result = await sut.fetchAllPersonalExpensesOf(userId, 2025, 5);

        // Assert
        verify(mockQuerySnapshot.docs).called(1);
        verify(mockQueryDocumentSnapshot.data()).called(2);
        expect(result.length, 2);
        expect(result[0]['amount'], 1000);
        expect(result[1]['amount'], 2000);
      });

      test('ドキュメントが存在しない場合、空のリストを返す', () async {
        // Arrange
        when(mockCollectionReference.where(
          'date',
          isGreaterThanOrEqualTo: DateTime(2025, 5, 1),
          isLessThan: DateTime(2025, 6, 1),
        )).thenReturn(mockQuery);
        when(mockQuerySnapshot.docs).thenReturn([]);

        final sut = FirestoreService(mockDb);

        // Act
        final result = await sut.fetchAllPersonalExpensesOf(userId, 2025, 5);

        // Assert
        verify(mockQuerySnapshot.docs).called(1);
        expect(result.length, 0);
      });

      test('不適切なmonthとdayの組み合わせの場合、assertionエラーが発生する', () async {
        // Arrange
        final sut = FirestoreService(mockDb);

        // Act & Assert
        expect(() => sut.fetchAllPersonalExpensesOf(userId, 2025, null, 25),
            throwsA(isA<AssertionError>()));
      });
    });
  });
}
