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
  group('fetchMonthly', () {
    late MockFirebaseFirestore mockDb;
    late MockCollectionReference<Map<String, dynamic>> mockCollectionReference;
    late MockQuery<Map<String, dynamic>> mockQuery;
    late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;
    late MockQueryDocumentSnapshot<Map<String, dynamic>>
        mockQueryDocumentSnapshot;

    setUp(() {
      mockDb = MockFirebaseFirestore();
      mockCollectionReference = MockCollectionReference();
      mockQuery = MockQuery();
      mockQuerySnapshot = MockQuerySnapshot();
      mockQueryDocumentSnapshot = MockQueryDocumentSnapshot();

      when(mockDb.collection('/personalNotes/samplePersonalNoteId/expenses'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.where(
        'date',
        isGreaterThanOrEqualTo: DateTime(2025, 1),
        isLessThan: DateTime(2025, 2),
      )).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
    });

    group('1件取得', () {
      <({String description, DateTime date})>[
        (
          description: '指定された月の支出一覧を取得できる',
          date: DateTime(2025, 1),
        ),
        (
          description: '初日の0時以外の日付を指定されたとき、月初の0時に整形してからデータを取得する',
          date: DateTime(2025, 1, 2, 3, 4, 5),
        ),
      ].forEach((element) {
        final (:description, :date) = element;
        test(description, () async {
          when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot]);
          when(mockQueryDocumentSnapshot.data()).thenReturn({'amount': 100});

          final sut = FirebaseExpenseRepository(
            mockDb,
            '/personalNotes/samplePersonalNoteId/expenses',
          );
          final expenseList = await sut.fetchMonthly(date);

          verify(
            mockDb.collection(
              '/personalNotes/samplePersonalNoteId/expenses',
            ),
          ).called(1);
          verify(mockCollectionReference.where(
            'date',
            isGreaterThanOrEqualTo: DateTime(2025, 1), // 日付の下限
            isLessThan: DateTime(2025, 2), // 日付の上限
          )).called(1);
          verify(mockQuery.get()).called(1);
          verify(mockQuerySnapshot.docs).called(1);
          verify(mockQueryDocumentSnapshot.data()).called(1);

          expect(expenseList, hasLength(1));
          expect(expenseList[0], Expense(100));
        });
      });
    });

    group('0件取得', () {
      test('指定された月の支出一覧を取得できる', () async {
        when(mockQuerySnapshot.docs).thenReturn([]);

        final sut = FirebaseExpenseRepository(
          mockDb,
          '/personalNotes/samplePersonalNoteId/expenses',
        );
        final expenseList = await sut.fetchMonthly(DateTime(2025, 1));

        // クエリの正しさは別のテストで確認しているので、取得した結果だけ確認
        expect(expenseList, hasLength(0));
      });
    });

    group('2件取得', () {
      test('指定された月の支出一覧を取得できる', () async {
        when(mockQuerySnapshot.docs).thenReturn([
          mockQueryDocumentSnapshot,
          mockQueryDocumentSnapshot,
        ]);
        when(mockQueryDocumentSnapshot.data()).thenReturnInOrder([
          {'amount': 100},
          {'amount': 200},
        ]);

        final sut = FirebaseExpenseRepository(
          mockDb,
          '/personalNotes/samplePersonalNoteId/expenses',
        );
        final expenseList = await sut.fetchMonthly(DateTime(2025, 1));

        // クエリの正しさは別のテストで確認しているので、取得した結果だけ確認
        expect(expenseList, hasLength(2));
        expect(expenseList[0], Expense(100));
        expect(expenseList[1], Expense(200));
      });
    });

    <({String description, dynamic value})>[
      (
        description: 'amountが数値以外のとき、TypeErrorが発生する',
        value: '100',
      ),
      (
        description: 'amountがnullのとき、TypeErrorが発生する',
        value: null,
      ),
    ].forEach((element) {
      final (:description, :value) = element;
      test(description, () async {
        when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot]);
        when(mockQueryDocumentSnapshot.data()).thenReturn({'amount': value});

        final sut = FirebaseExpenseRepository(
          mockDb,
          '/personalNotes/samplePersonalNoteId/expenses',
        );
        expect(() async => await sut.fetchMonthly(DateTime(2025, 1)),
            throwsA(isA<TypeError>()));
      });
    });
  });
}
