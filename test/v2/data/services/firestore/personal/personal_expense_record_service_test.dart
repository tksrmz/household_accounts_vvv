import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: unused_import
import 'package:dartz/dartz.dart';
import 'package:household_accounts/v2/data/models/expense_record_model.dart';
import 'package:household_accounts/v2/data/services/firestore/personal/personal_expense_record_service.dart';
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
import 'personal_expense_record_service_test.mocks.dart';

void main() {
  group('PersonalExpenseRecordService', () {
    group('fetchByDate', () {
      final mockDb = MockFirebaseFirestore();
      final mockCollectionReference = MockCollectionReference();
      final mockQuery = MockQuery();
      final mockQuerySnapshot = MockQuerySnapshot();
      final mockQueryDocumentSnapshot = MockQueryDocumentSnapshot();
      final userId = UserIdVo('testUserId');

      setUp(() {
        when(mockDb.collection('/personalNotes/${userId.value}/expenses'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.where(
          any,
          isGreaterThanOrEqualTo: anyNamed('isGreaterThanOrEqualTo'),
          isLessThan: anyNamed('isLessThan'),
        )).thenReturn(mockQuery);
        when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot]);
        when(mockQueryDocumentSnapshot.id).thenReturn('expenseId1');
        when(mockQueryDocumentSnapshot.data()).thenReturn({
          'date': Timestamp.fromDate(DateTime(2025, 5, 25)),
          'amount': 1000,
          'note': 'Test expense',
          'hasCheckedOut': false,
          'createdAt': Timestamp.fromDate(DateTime(2025, 5, 25)),
          'property': {'ref': 'propertyRef'},
          'category': {'ref': 'categoryRef'},
          'type': 'expense',
        });
      });

      tearDown(() {
        reset(mockDb);
        reset(mockCollectionReference);
        reset(mockQuery);
        reset(mockQuerySnapshot);
        reset(mockQueryDocumentSnapshot);
      });

      test('年月を指定して支出レコードを取得できる', () async {
        // Arrange
        final target = PersonalExpenseRecordService(mockDb);

        // Act
        final result = await target.fetchByDate(userId, 2025, 5);

        // Assert
        verify(mockDb.collection('/personalNotes/${userId.value}/expenses'))
            .called(1);
        verify(mockCollectionReference.where(any,
                isGreaterThanOrEqualTo: anyNamed('isGreaterThanOrEqualTo'),
                isLessThan: anyNamed('isLessThan')))
            .called(1);
        verify(mockQuery.get()).called(1);
        verify(mockQuerySnapshot.docs).called(1);
        verify(mockQueryDocumentSnapshot.data()).called(1);

        expect(result.isRight(), isTrue);
        final expenses = result.getOrElse(List.empty);
        expect(expenses, hasLength(1));
        expect(expenses[0].id, 'expenseId1');
        expect(expenses[0].amount, 1000);
        expect(expenses[0].note, 'Test expense');
      });

      test('年のみを指定して支出レコードを取得できる', () async {
        // Arrange
        final target = PersonalExpenseRecordService(mockDb);

        // Act
        final result = await target.fetchByDate(userId, 2025);

        // Assert
        expect(result.isRight(), isTrue);
      });

      test('日付を指定して支出レコードを取得できる', () async {
        // Arrange
        final target = PersonalExpenseRecordService(mockDb);

        // Act
        final result = await target.fetchByDate(userId, 2025, 5, 25);

        // Assert
        expect(result.isRight(), isTrue);
      });

      test('例外が発生した場合、Leftを返す', () async {
        // Arrange
        when(mockQuery.get()).thenThrow(Exception('test error'));
        final target = PersonalExpenseRecordService(mockDb);

        // Act
        final result = await target.fetchByDate(userId, 2025, 5);

        // Assert
        expect(result.isLeft(), isTrue);
      });

      test('月がnullで日が指定された場合、アサーションエラーが発生する', () async {
        // Arrange
        final target = PersonalExpenseRecordService(mockDb);

        // Act & Assert
        expect(() => target.fetchByDate(userId, 2025, null, 25),
            throwsA(isA<AssertionError>()));
      });
    });

    group('add', () {
      final mockDb = MockFirebaseFirestore();
      final mockCollectionReference = MockCollectionReference();
      final mockDocumentReference = MockDocumentReference();
      final userId = UserIdVo('testUserId');
      final expense = ExpenseRecordModel(
        id: 'expenseId1',
        date: DateTime(2025, 5, 25),
        amount: 1000,
        note: 'Test expense',
        hasCheckedOut: false,
        createdAt: DateTime(2025, 5, 25),
        property: {'ref': 'propertyRef'},
        category: {'ref': 'categoryRef'},
      );

      setUp(() {
        when(mockDb.collection('/personalNotes/${userId.value}/expenses'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(expense.id))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.set(any)).thenAnswer((_) async => {});
      });

      tearDown(() {
        reset(mockDb);
        reset(mockCollectionReference);
        reset(mockDocumentReference);
      });

      test('支出レコードを追加できる', () async {
        // Arrange
        final target = PersonalExpenseRecordService(mockDb);

        // Act
        final result = await target.add(userId, expense);

        // Assert
        verify(mockDb.collection('/personalNotes/${userId.value}/expenses'))
            .called(1);
        verify(mockCollectionReference.doc(expense.id)).called(1);
        verify(mockDocumentReference.set(any)).called(1);

        expect(result.isRight(), isTrue);
      });

      test('例外が発生した場合、Leftを返す', () async {
        // Arrange
        when(mockDocumentReference.set(any)).thenThrow(Exception('test error'));
        final target = PersonalExpenseRecordService(mockDb);

        // Act
        final result = await target.add(userId, expense);

        // Assert
        expect(result.isLeft(), isTrue);
      });
    });

    group('delete', () {
      final mockDb = MockFirebaseFirestore();
      final mockCollectionReference = MockCollectionReference();
      final mockDocumentReference = MockDocumentReference();
      final userId = UserIdVo('testUserId');
      final expenseId = 'expenseId1';

      setUp(() {
        when(mockDb.collection('/personalNotes/${userId.value}/expenses'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(expenseId))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.delete()).thenAnswer((_) async => {});
      });

      tearDown(() {
        reset(mockDb);
        reset(mockCollectionReference);
        reset(mockDocumentReference);
      });

      test('支出レコードを削除できる', () async {
        // Arrange
        final target = PersonalExpenseRecordService(mockDb);

        // Act
        final result = await target.delete(userId, expenseId);

        // Assert
        verify(mockDb.collection('/personalNotes/${userId.value}/expenses'))
            .called(1);
        verify(mockCollectionReference.doc(expenseId)).called(1);
        verify(mockDocumentReference.delete()).called(1);

        expect(result.isRight(), isTrue);
      });

      test('例外が発生した場合、Leftを返す', () async {
        // Arrange
        when(mockDocumentReference.delete()).thenThrow(Exception('test error'));
        final target = PersonalExpenseRecordService(mockDb);

        // Act
        final result = await target.delete(userId, expenseId);

        // Assert
        expect(result.isLeft(), isTrue);
      });
    });
  });
}
