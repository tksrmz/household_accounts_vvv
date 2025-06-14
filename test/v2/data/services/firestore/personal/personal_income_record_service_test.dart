import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:household_accounts/v2/data/models/income_record_model.dart';
import 'package:household_accounts/v2/data/services/firestore/personal/personal_income_record_service.dart';
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
  MockSpec<DocumentReference<Map<String, dynamic>>>(),
])
import 'personal_income_record_service_test.mocks.dart';

void main() {
  group('PersonalIncomeRecordService', () {
    group('fetchPersonalIncomes', () {
      final mockDb = MockFirebaseFirestore();
      final mockCollectionReference = MockCollectionReference();
      final mockQuery = MockQuery();
      final mockQuerySnapshot = MockQuerySnapshot();
      final mockQueryDocumentSnapshot = MockQueryDocumentSnapshot();
      final userId = UserIdVo('testUserId');

      setUp(() {
        when(mockDb.collection('/personalNotes/${userId.value}/incomes'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.where(any, isGreaterThanOrEqualTo: anyNamed('isGreaterThanOrEqualTo'), isLessThan: anyNamed('isLessThan')))
            .thenReturn(mockQuery);
        when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot]);
        when(mockQueryDocumentSnapshot.id).thenReturn('incomeId1');
        when(mockQueryDocumentSnapshot.data()).thenReturn({
          'date': Timestamp.fromDate(DateTime(2025, 5, 25)),
          'amount': 5000,
          'note': 'Test income',
          'hasCheckedOut': false,
          'createdAt': Timestamp.fromDate(DateTime(2025, 5, 25)),
          'property': {'ref': 'propertyRef'},
          'category': {'ref': 'categoryRef'},
          'type': 'income',
        });
      });

      tearDown(() {
        reset(mockDb);
        reset(mockCollectionReference);
        reset(mockQuery);
        reset(mockQuerySnapshot);
        reset(mockQueryDocumentSnapshot);
      });

      test('年月を指定して収入レコードを取得できる', () async {
        // Arrange
        final target = PersonalIncomeRecordService(mockDb);

        // Act
        final result = await target.fetchPersonalIncomes(userId, 2025, 5);

        // Assert
        verify(mockDb.collection('/personalNotes/${userId.value}/incomes'))
            .called(1);
        verify(mockCollectionReference.where(any, isGreaterThanOrEqualTo: anyNamed('isGreaterThanOrEqualTo'), isLessThan: anyNamed('isLessThan')))
            .called(1);
        verify(mockQuery.get()).called(1);
        verify(mockQuerySnapshot.docs).called(1);
        verify(mockQueryDocumentSnapshot.data()).called(1);

        expect(result.isRight(), isTrue);
        final incomes = result.getOrElse(List.empty);
        expect(incomes, hasLength(1));
        expect(incomes[0].id, 'incomeId1');
        expect(incomes[0].amount, 5000);
        expect(incomes[0].note, 'Test income');
      });

      test('年のみを指定して収入レコードを取得できる', () async {
        // Arrange
        final target = PersonalIncomeRecordService(mockDb);

        // Act
        final result = await target.fetchPersonalIncomes(userId, 2025);

        // Assert
        expect(result.isRight(), isTrue);
      });

      test('日付を指定して収入レコードを取得できる', () async {
        // Arrange
        final target = PersonalIncomeRecordService(mockDb);

        // Act
        final result = await target.fetchPersonalIncomes(userId, 2025, 5, 25);

        // Assert
        expect(result.isRight(), isTrue);
      });

      test('例外が発生した場合、Leftを返す', () async {
        // Arrange
        when(mockQuery.get()).thenThrow(Exception('test error'));
        final target = PersonalIncomeRecordService(mockDb);

        // Act
        final result = await target.fetchPersonalIncomes(userId, 2025, 5);

        // Assert
        expect(result.isLeft(), isTrue);
      });

      test('月がnullで日が指定された場合、アサーションエラーが発生する', () async {
        // Arrange
        final target = PersonalIncomeRecordService(mockDb);

        // Act & Assert
        expect(() => target.fetchPersonalIncomes(userId, 2025, null, 25),
            throwsA(isA<AssertionError>()));
      });
    });

    group('addPersonalIncome', () {
      final mockDb = MockFirebaseFirestore();
      final mockCollectionReference = MockCollectionReference();
      final mockDocumentReference = MockDocumentReference();
      final userId = UserIdVo('testUserId');
      final income = IncomeRecordModel(
        id: 'incomeId1',
        date: DateTime(2025, 5, 25),
        amount: 5000,
        note: 'Test income',
        hasCheckedOut: false,
        createdAt: DateTime(2025, 5, 25),
        property: {'ref': 'propertyRef'},
        category: {'ref': 'categoryRef'},
      );

      setUp(() {
        when(mockDb.collection('/personalNotes/${userId.value}/incomes'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(income.id))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.set(any)).thenAnswer((_) async => {});
      });

      tearDown(() {
        reset(mockDb);
        reset(mockCollectionReference);
        reset(mockDocumentReference);
      });

      test('収入レコードを追加できる', () async {
        // Arrange
        final target = PersonalIncomeRecordService(mockDb);

        // Act
        final result = await target.addPersonalIncome(userId, income);

        // Assert
        verify(mockDb.collection('/personalNotes/${userId.value}/incomes'))
            .called(1);
        verify(mockCollectionReference.doc(income.id)).called(1);
        verify(mockDocumentReference.set(any)).called(1);

        expect(result.isRight(), isTrue);
      });

      test('例外が発生した場合、Leftを返す', () async {
        // Arrange
        when(mockDocumentReference.set(any)).thenThrow(Exception('test error'));
        final target = PersonalIncomeRecordService(mockDb);

        // Act
        final result = await target.addPersonalIncome(userId, income);

        // Assert
        expect(result.isLeft(), isTrue);
      });
    });

    group('deletePersonalIncome', () {
      final mockDb = MockFirebaseFirestore();
      final mockCollectionReference = MockCollectionReference();
      final mockDocumentReference = MockDocumentReference();
      final userId = UserIdVo('testUserId');
      final incomeId = 'incomeId1';

      setUp(() {
        when(mockDb.collection('/personalNotes/${userId.value}/incomes'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(incomeId))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.delete()).thenAnswer((_) async => {});
      });

      tearDown(() {
        reset(mockDb);
        reset(mockCollectionReference);
        reset(mockDocumentReference);
      });

      test('収入レコードを削除できる', () async {
        // Arrange
        final target = PersonalIncomeRecordService(mockDb);

        // Act
        final result = await target.deletePersonalIncome(userId, incomeId);

        // Assert
        verify(mockDb.collection('/personalNotes/${userId.value}/incomes'))
            .called(1);
        verify(mockCollectionReference.doc(incomeId)).called(1);
        verify(mockDocumentReference.delete()).called(1);

        expect(result.isRight(), isTrue);
      });

      test('例外が発生した場合、Leftを返す', () async {
        // Arrange
        when(mockDocumentReference.delete()).thenThrow(Exception('test error'));
        final target = PersonalIncomeRecordService(mockDb);

        // Act
        final result = await target.deletePersonalIncome(userId, incomeId);

        // Assert
        expect(result.isLeft(), isTrue);
      });
    });
  });
}