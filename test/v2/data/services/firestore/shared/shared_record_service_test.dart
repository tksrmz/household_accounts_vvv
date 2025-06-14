import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:household_accounts/v2/data/services/firestore/shared/shared_record_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseFirestore>(),
  MockSpec<DocumentReference<Map<String, dynamic>>>(),
  MockSpec<CollectionReference<Map<String, dynamic>>>(),
  MockSpec<Query<Map<String, dynamic>>>(),
  MockSpec<QuerySnapshot<Map<String, dynamic>>>(),
  MockSpec<QueryDocumentSnapshot<Map<String, dynamic>>>(),
])
import 'shared_record_service_test.mocks.dart';

void main() {
  group('SharedRecordService', () {
    group('fetchMonthlySharedExpensesFrom', () {
      final mockDb = MockFirebaseFirestore();
      final mockSharedNoteDocRef = MockDocumentReference();
      final mockCollectionReference = MockCollectionReference();
      final mockQuery = MockQuery();
      final mockQuerySnapshot = MockQuerySnapshot();
      final mockQueryDocumentSnapshot = MockQueryDocumentSnapshot();

      setUp(() {
        when(mockSharedNoteDocRef.collection('expenses'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.where(any, isGreaterThanOrEqualTo: anyNamed('isGreaterThanOrEqualTo'), isLessThan: anyNamed('isLessThan')))
            .thenReturn(mockQuery);
        when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot]);
        when(mockQueryDocumentSnapshot.data()).thenReturn({
          'date': Timestamp.fromDate(DateTime(2025, 5, 25)),
          'amount': 1000,
          'note': 'Test shared expense',
          'hasCheckedOut': false,
          'createdAt': Timestamp.fromDate(DateTime(2025, 5, 25)),
          'property': {'ref': 'propertyRef'},
          'category': {'ref': 'categoryRef'},
          'type': 'expense',
        });
      });

      tearDown(() {
        reset(mockDb);
        reset(mockSharedNoteDocRef);
        reset(mockCollectionReference);
        reset(mockQuery);
        reset(mockQuerySnapshot);
        reset(mockQueryDocumentSnapshot);
      });

      test('年月を指定して共有支出レコードを取得できる', () async {
        // Arrange
        final target = SharedRecordService(mockDb);

        // Act
        final result = await target.fetchMonthlySharedExpensesFrom(
            mockSharedNoteDocRef, 2025, 5);

        // Assert
        verify(mockSharedNoteDocRef.collection('expenses')).called(1);
        verify(mockCollectionReference.where(any, isGreaterThanOrEqualTo: anyNamed('isGreaterThanOrEqualTo'), isLessThan: anyNamed('isLessThan')))
            .called(1);
        verify(mockQuery.get()).called(1);
        verify(mockQuerySnapshot.docs).called(1);
        verify(mockQueryDocumentSnapshot.data()).called(1);

        expect(result.isRight(), isTrue);
        final expenses = result.getOrElse(List.empty);
        expect(expenses, hasLength(1));
        expect(expenses[0]['amount'], 1000);
        expect(expenses[0]['note'], 'Test shared expense');
      });

      test('年のみを指定して共有支出レコードを取得できる', () async {
        // Arrange
        final target = SharedRecordService(mockDb);

        // Act
        final result = await target.fetchMonthlySharedExpensesFrom(
            mockSharedNoteDocRef, 2025);

        // Assert
        expect(result.isRight(), isTrue);
      });

      test('日付を指定して共有支出レコードを取得できる', () async {
        // Arrange
        final target = SharedRecordService(mockDb);

        // Act
        final result = await target.fetchMonthlySharedExpensesFrom(
            mockSharedNoteDocRef, 2025, 5, 25);

        // Assert
        expect(result.isRight(), isTrue);
      });

      test('例外が発生した場合、Leftを返す', () async {
        // Arrange
        when(mockQuery.get()).thenThrow(Exception('test error'));
        final target = SharedRecordService(mockDb);

        // Act
        final result = await target.fetchMonthlySharedExpensesFrom(
            mockSharedNoteDocRef, 2025, 5);

        // Assert
        expect(result.isLeft(), isTrue);
      });

      test('月がnullで日が指定された場合、アサーションエラーが発生する', () async {
        // Arrange
        final target = SharedRecordService(mockDb);

        // Act & Assert
        expect(() => target.fetchMonthlySharedExpensesFrom(
            mockSharedNoteDocRef, 2025, null, 25),
            throwsA(isA<AssertionError>()));
      });
    });

    group('fetchMonthlySharedIncomesFrom', () {
      final mockDb = MockFirebaseFirestore();
      final mockSharedNoteDocRef = MockDocumentReference();
      final mockCollectionReference = MockCollectionReference();
      final mockQuery = MockQuery();
      final mockQuerySnapshot = MockQuerySnapshot();
      final mockQueryDocumentSnapshot = MockQueryDocumentSnapshot();

      setUp(() {
        when(mockSharedNoteDocRef.collection('incomes'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.where(any, isGreaterThanOrEqualTo: anyNamed('isGreaterThanOrEqualTo'), isLessThan: anyNamed('isLessThan')))
            .thenReturn(mockQuery);
        when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot]);
        when(mockQueryDocumentSnapshot.data()).thenReturn({
          'date': Timestamp.fromDate(DateTime(2025, 5, 25)),
          'amount': 5000,
          'note': 'Test shared income',
          'hasCheckedOut': false,
          'createdAt': Timestamp.fromDate(DateTime(2025, 5, 25)),
          'property': {'ref': 'propertyRef'},
          'category': {'ref': 'categoryRef'},
          'type': 'income',
        });
      });

      tearDown(() {
        reset(mockDb);
        reset(mockSharedNoteDocRef);
        reset(mockCollectionReference);
        reset(mockQuery);
        reset(mockQuerySnapshot);
        reset(mockQueryDocumentSnapshot);
      });

      test('年月を指定して共有収入レコードを取得できる', () async {
        // Arrange
        final target = SharedRecordService(mockDb);

        // Act
        final result = await target.fetchMonthlySharedIncomesFrom(
            mockSharedNoteDocRef, 2025, 5);

        // Assert
        verify(mockSharedNoteDocRef.collection('incomes')).called(1);
        verify(mockCollectionReference.where(any, isGreaterThanOrEqualTo: anyNamed('isGreaterThanOrEqualTo'), isLessThan: anyNamed('isLessThan')))
            .called(1);
        verify(mockQuery.get()).called(1);
        verify(mockQuerySnapshot.docs).called(1);
        verify(mockQueryDocumentSnapshot.data()).called(1);

        expect(result.isRight(), isTrue);
        final incomes = result.getOrElse(List.empty);
        expect(incomes, hasLength(1));
        expect(incomes[0]['amount'], 5000);
        expect(incomes[0]['note'], 'Test shared income');
      });

      test('年のみを指定して共有収入レコードを取得できる', () async {
        // Arrange
        final target = SharedRecordService(mockDb);

        // Act
        final result = await target.fetchMonthlySharedIncomesFrom(
            mockSharedNoteDocRef, 2025);

        // Assert
        expect(result.isRight(), isTrue);
      });

      test('日付を指定して共有収入レコードを取得できる', () async {
        // Arrange
        final target = SharedRecordService(mockDb);

        // Act
        final result = await target.fetchMonthlySharedIncomesFrom(
            mockSharedNoteDocRef, 2025, 5, 25);

        // Assert
        expect(result.isRight(), isTrue);
      });

      test('例外が発生した場合、Leftを返す', () async {
        // Arrange
        when(mockQuery.get()).thenThrow(Exception('test error'));
        final target = SharedRecordService(mockDb);

        // Act
        final result = await target.fetchMonthlySharedIncomesFrom(
            mockSharedNoteDocRef, 2025, 5);

        // Assert
        expect(result.isLeft(), isTrue);
      });

      test('月がnullで日が指定された場合、アサーションエラーが発生する', () async {
        // Arrange
        final target = SharedRecordService(mockDb);

        // Act & Assert
        expect(() => target.fetchMonthlySharedIncomesFrom(
            mockSharedNoteDocRef, 2025, null, 25),
            throwsA(isA<AssertionError>()));
      });
    });
  });
}