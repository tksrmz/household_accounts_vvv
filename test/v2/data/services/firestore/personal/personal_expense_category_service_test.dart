import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: unused_import
import 'package:dartz/dartz.dart';
import 'package:household_accounts/v2/data/models/expense_category_model.dart';
import 'package:household_accounts/v2/data/services/firestore/personal/personal_expense_category_service.dart';
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
import 'personal_expense_category_service_test.mocks.dart';

void main() {
  group('PersonalExpenseCategoryService', () {
    group('fetchAll', () {
      final mockDb = MockFirebaseFirestore();
      final mockCollectionReference = MockCollectionReference();
      final mockQuerySnapshot = MockQuerySnapshot();
      final mockQueryDocumentSnapshot = MockQueryDocumentSnapshot();
      final userId = UserIdVo('testUserId');

      setUp(() {
        when(
          mockDb.collection('/personalNotes/${userId.value}/expenseCategories'),
        ).thenReturn(mockCollectionReference);
        when(
          mockCollectionReference.get(),
        ).thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot]);
        when(mockQueryDocumentSnapshot.id).thenReturn('categoryId1');
        when(mockQueryDocumentSnapshot.data()).thenReturn({
          'name': 'Test Expense Category',
          'type': 'expense',
          'totalBudget': 50000,
        });
      });

      tearDown(() {
        reset(mockDb);
        reset(mockCollectionReference);
        reset(mockQuerySnapshot);
        reset(mockQueryDocumentSnapshot);
      });

      test('支出カテゴリのリストを取得できる', () async {
        // Arrange
        final target = PersonalExpenseCategoryService(mockDb);

        // Act
        final result = await target.fetchAll(userId);

        // Assert
        verify(
          mockDb.collection('/personalNotes/${userId.value}/expenseCategories'),
        ).called(1);
        verify(mockCollectionReference.get()).called(1);
        verify(mockQuerySnapshot.docs).called(1);
        verify(mockQueryDocumentSnapshot.data()).called(1);

        expect(result.isRight(), isTrue);
        final categories = result.getOrElse(List.empty);
        expect(categories, hasLength(1));
        expect(categories[0].id, 'categoryId1');
        expect(categories[0].name, 'Test Expense Category');
        expect(categories[0].totalBudget, 50000);
      });

      test('例外が発生した場合、Leftを返す', () async {
        // Arrange
        when(mockCollectionReference.get()).thenThrow(Exception('test error'));
        final target = PersonalExpenseCategoryService(mockDb);

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
      final category = ExpenseCategoryModel(
        id: 'categoryId1',
        name: 'Test Category',
        totalBudget: 50000,
      );

      setUp(() {
        when(
          mockDb.collection('/personalNotes/${userId.value}/expenseCategories'),
        ).thenReturn(mockCollectionReference);
        when(
          mockCollectionReference.doc(category.id),
        ).thenReturn(mockDocumentReference);
        when(mockDocumentReference.set(any)).thenAnswer((_) async => {});
      });

      tearDown(() {
        reset(mockDb);
        reset(mockCollectionReference);
        reset(mockDocumentReference);
      });

      test('支出カテゴリを追加できる', () async {
        // Arrange
        final target = PersonalExpenseCategoryService(mockDb);

        // Act
        final result = await target.add(userId, category);

        // Assert
        verify(
          mockDb.collection('/personalNotes/${userId.value}/expenseCategories'),
        ).called(1);
        verify(mockCollectionReference.doc(category.id)).called(1);
        verify(mockDocumentReference.set(any)).called(1);

        expect(result.isRight(), isTrue);
      });

      test('例外が発生した場合、Leftを返す', () async {
        // Arrange
        when(mockDocumentReference.set(any)).thenThrow(Exception('test error'));
        final target = PersonalExpenseCategoryService(mockDb);

        // Act
        final result = await target.add(userId, category);

        // Assert
        expect(result.isLeft(), isTrue);
      });
    });

    group('update', () {
      final mockDb = MockFirebaseFirestore();
      final mockCollectionReference = MockCollectionReference();
      final mockDocumentReference = MockDocumentReference();
      final userId = UserIdVo('testUserId');
      final category = ExpenseCategoryModel(
        id: 'categoryId1',
        name: 'Updated Category',
        totalBudget: 75000,
      );

      setUp(() {
        when(
          mockDb.collection('/personalNotes/${userId.value}/expenseCategories'),
        ).thenReturn(mockCollectionReference);
        when(
          mockCollectionReference.doc(category.id),
        ).thenReturn(mockDocumentReference);
        when(mockDocumentReference.update(any)).thenAnswer((_) async => {});
      });

      tearDown(() {
        reset(mockDb);
        reset(mockCollectionReference);
        reset(mockDocumentReference);
      });

      test('支出カテゴリを更新できる', () async {
        // Arrange
        final target = PersonalExpenseCategoryService(mockDb);

        // Act
        final result = await target.update(userId, category);

        // Assert
        verify(
          mockDb.collection('/personalNotes/${userId.value}/expenseCategories'),
        ).called(1);
        verify(mockCollectionReference.doc(category.id)).called(1);
        verify(mockDocumentReference.update(any)).called(1);

        expect(result.isRight(), isTrue);
      });

      test('例外が発生した場合、Leftを返す', () async {
        // Arrange
        when(
          mockDocumentReference.update(any),
        ).thenThrow(Exception('test error'));
        final target = PersonalExpenseCategoryService(mockDb);

        // Act
        final result = await target.update(userId, category);

        // Assert
        expect(result.isLeft(), isTrue);
      });
    });

    group('delete', () {
      final mockDb = MockFirebaseFirestore();
      final mockCollectionReference = MockCollectionReference();
      final mockDocumentReference = MockDocumentReference();
      final userId = UserIdVo('testUserId');
      final categoryId = 'categoryId1';

      setUp(() {
        when(
          mockDb.collection('/personalNotes/${userId.value}/expenseCategories'),
        ).thenReturn(mockCollectionReference);
        when(
          mockCollectionReference.doc(categoryId),
        ).thenReturn(mockDocumentReference);
        when(mockDocumentReference.delete()).thenAnswer((_) async => {});
      });

      tearDown(() {
        reset(mockDb);
        reset(mockCollectionReference);
        reset(mockDocumentReference);
      });

      test('支出カテゴリを削除できる', () async {
        // Arrange
        final target = PersonalExpenseCategoryService(mockDb);

        // Act
        final result = await target.delete(userId, categoryId);

        // Assert
        verify(
          mockDb.collection('/personalNotes/${userId.value}/expenseCategories'),
        ).called(1);
        verify(mockCollectionReference.doc(categoryId)).called(1);
        verify(mockDocumentReference.delete()).called(1);

        expect(result.isRight(), isTrue);
      });

      test('例外が発生した場合、Leftを返す', () async {
        // Arrange
        when(mockDocumentReference.delete()).thenThrow(Exception('test error'));
        final target = PersonalExpenseCategoryService(mockDb);

        // Act
        final result = await target.delete(userId, categoryId);

        // Assert
        expect(result.isLeft(), isTrue);
      });
    });
  });
}
