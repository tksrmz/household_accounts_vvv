import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:household_accounts/entity/expense.dart';
import 'package:household_accounts/presentation/dashboard/data/firebase_expense_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseFirestore>(),
  MockSpec<CollectionReference>(),
  MockSpec<DocumentReference>(),
  MockSpec<DocumentSnapshot>(),
  MockSpec<Query>(),
  MockSpec<QuerySnapshot>(),
  MockSpec<QueryDocumentSnapshot>(),
])
import 'firebase_income_repository_test.mocks.dart';

void main() {
  <({String description, DateTime date})>[
    (
      description: 'fetchMonthlyで指定された月の支出一覧を取得できる',
      date: DateTime(2025, 1),
    ),
    (
      description: 'fetchMonthlyで初日の0時以外の日付を指定されたとき、月初の0時に整形してからデータを取得する',
      date: DateTime(2025, 1, 2, 3, 4, 5),
    ),
  ].forEach((element) {
    final (:description, :date) = element;
    test(description, () async {
      final mockDb = MockFirebaseFirestore();
      final mockCollectionReference =
          MockCollectionReference<Map<String, dynamic>>();
      final mockQuery = MockQuery<Map<String, dynamic>>();
      final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
      final mockQueryDocumentSnapshot =
          MockQueryDocumentSnapshot<Map<String, dynamic>>();

      when(mockDb.collection('hoge')).thenReturn(mockCollectionReference);
      when(mockCollectionReference.where(
        'date',
        isGreaterThanOrEqualTo: DateTime(2025, 1),
      )).thenReturn(mockQuery);
      when(mockQuery.where(
        'date',
        isLessThan: DateTime(2025, 2),
      )).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot]);
      when(mockQueryDocumentSnapshot.data()).thenReturn({'amount': 100});

      final sut = FirebaseExpenseRepository(mockDb);
      final expenseList = await sut.fetchMonthly(date);

      verify(mockDb.collection('hoge')).called(1);
      // 日付の下限
      verify(mockCollectionReference.where(
        'date',
        isGreaterThanOrEqualTo: DateTime(2025, 1),
      )).called(1);
      // 日付の上限
      verify(mockQuery.where(
        'date',
        isLessThan: DateTime(2025, 2),
      )).called(1);
      verify(mockQuery.get()).called(1);
      verify(mockQuerySnapshot.docs).called(1);
      verify(mockQueryDocumentSnapshot.data()).called(1);

      expect(expenseList, hasLength(1));
      expect(expenseList[0], Expense(100));
    });
  });
}
